//! ローカルにインストールされている Chrome / Edge / Chromium をヘッドレスモードで
//! 呼び出し、レポートページをPDFとして書き出すモジュール。
//!
//! Tauri / WRY には2026年6月現在、OS共通の「WebViewを無音でPDF化するAPI」は無いため
//! （Windows の WebView2 には PrintToPdfAsync があるが、Tauri からまだ統一的には
//! 公開されていない）、最初のサンプルでは最も枯れた方法として
//! 「OSにある実ブラウザをヘッドレスモードで起動し、--print-to-pdf を使う」方式を採用する。
//! Windows なら Edge が標準で入っているため、追加インストール無しで動く想定。
//!
//! 【既知の注意点】すでに通常のウィンドウでChrome/Edgeが起動している状態だと、
//! 既定のユーザープロファイル（--user-data-dir未指定）で新しく起動しようとしても、
//! シングルインスタンス機構により既存のプロセスに処理が転送されることがある。
//! その場合、相対パスの解決基準（カレントディレクトリ）が呼び出し元と食い違ったり、
//! 新規プロセスがすぐ終了コード0で返ってきてしまったりする。これを避けるため、
//! 毎回専用の一時プロファイルディレクトリ（--user-data-dir）を指定して起動し、
//! 出力パスは必ず絶対パスに変換してから渡す。

use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Debug, thiserror::Error)]
pub enum PdfError {
    #[error(
        "ヘッドレスで使えるブラウザ（Edge/Chrome/Chromium）が見つかりませんでした。\n\
         いずれかをインストールしてから再実行してください。"
    )]
    BrowserNotFound,
    #[error("ブラウザの起動に失敗しました: {0}")]
    Spawn(std::io::Error),
    #[error("PDF生成コマンドが失敗しました（終了コード: {0:?}）\n--- stderr ---\n{1}")]
    NonZeroExit(Option<i32>, String),
    #[error("PDFファイルが生成されませんでした: {0}")]
    OutputMissing(String),
}

/// OSごとのヘッドレスブラウザの候補名（PATH上の実行ファイル名 or 絶対パス）。
/// Linux では /opt/pw-browsers/ 以下にある Playwright 製 Chromium を動的に追加する。
fn browser_candidates() -> Vec<String> {
    #[allow(unused_mut)]
    let mut candidates: Vec<String> = if cfg!(target_os = "windows") {
        vec![
            "msedge".into(),
            "chrome".into(),
            r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe".into(),
            r"C:\Program Files\Microsoft\Edge\Application\msedge.exe".into(),
            r"C:\Program Files\Google\Chrome\Application\chrome.exe".into(),
            r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe".into(),
        ]
    } else if cfg!(target_os = "macos") {
        vec![
            "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome".into(),
            "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge".into(),
            "google-chrome".into(),
            "chromium".into(),
        ]
    } else {
        vec![
            "google-chrome".into(),
            "google-chrome-stable".into(),
            "microsoft-edge".into(),
            "chromium".into(),
            "chromium-browser".into(),
        ]
    };

    // Linux: Playwright がインストールする Chromium を動的に探す
    // /opt/pw-browsers/chromium-*/chrome-linux/chrome
    #[cfg(target_os = "linux")]
    {
        if let Ok(entries) = std::fs::read_dir("/opt/pw-browsers") {
            let mut pw_paths: Vec<String> = entries
                .flatten()
                .filter_map(|e| {
                    let name = e.file_name().into_string().ok()?;
                    if !name.starts_with("chromium-") { return None; }
                    let p = e.path().join("chrome-linux/chrome");
                    if p.exists() { Some(p.to_string_lossy().into_owned()) } else { None }
                })
                .collect();
            // バージョン番号の降順（新しい方が優先）
            pw_paths.sort_by(|a, b| b.cmp(a));
            candidates.extend(pw_paths);
        }
    }

    candidates
}

/// 相対パスを、現在のカレントディレクトリ基準の絶対パスに変換する。
/// （ブラウザ側プロセスが相対パスをどのディレクトリ基準で解決するか、
/// 環境やシングルインスタンス転送の有無によって食い違うことがあるための対策）
fn to_absolute(path: &Path) -> PathBuf {
    if path.is_absolute() {
        path.to_path_buf()
    } else {
        std::env::current_dir()
            .map(|cwd| cwd.join(path))
            .unwrap_or_else(|_| path.to_path_buf())
    }
}

fn unique_suffix() -> u128 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_nanos())
        .unwrap_or(0)
}

/// 指定したURLをヘッドレスブラウザで開いてPDFとして保存する。
/// virtual_time_budget_ms: 非同期処理（fetchでのJSON読み込みなど）を待つための仮想時間（ミリ秒）。
pub fn render_url_to_pdf(
    url: &str,
    output_path: &Path,
    virtual_time_budget_ms: u32,
) -> Result<(), PdfError> {
    let candidates = browser_candidates();
    let mut last_err: Option<PdfError> = None;

    let abs_output_path = to_absolute(output_path);

    // 既存の通常起動中のブラウザ（既定プロファイル）と衝突して処理が転送されないよう、
    // 実行ごとに専用の一時プロファイルディレクトリを使う。
    let profile_dir = std::env::temp_dir().join(format!(
        "secAdvisoryTool-pdf-{}-{}",
        std::process::id(),
        unique_suffix()
    ));
    let _ = std::fs::create_dir_all(&profile_dir);

    for browser in &candidates {
        let output_arg = format!("--print-to-pdf={}", abs_output_path.display());
        let vtb_arg = format!("--virtual-time-budget={}", virtual_time_budget_ms);
        let profile_arg = format!("--user-data-dir={}", profile_dir.display());

        let result = Command::new(browser)
            .args([
                "--headless=new",
                "--disable-gpu",
                "--no-sandbox",
                "--no-pdf-header-footer",
                "--print-to-pdf-no-header",
                &profile_arg,
                &vtb_arg,
                &output_arg,
                url,
            ])
            .output();

        match result {
            Ok(out) => {
                if abs_output_path.exists() {
                    let size = std::fs::metadata(&abs_output_path)
                        .map(|m| m.len())
                        .unwrap_or(0);
                    if size == 0 {
                        last_err = Some(PdfError::OutputMissing(
                            abs_output_path.display().to_string(),
                        ));
                        continue;
                    }
                    let _ = std::fs::remove_dir_all(&profile_dir);
                    return Ok(());
                }
                let stderr = String::from_utf8_lossy(&out.stderr).to_string();
                last_err = Some(PdfError::NonZeroExit(out.status.code(), stderr));
            }
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => {
                // この候補ブラウザは存在しない。次の候補を試す。
                continue;
            }
            Err(e) => {
                last_err = Some(PdfError::Spawn(e));
            }
        }
    }

    let _ = std::fs::remove_dir_all(&profile_dir);
    Err(last_err.unwrap_or(PdfError::BrowserNotFound))
}
