//! アドバイザリ入力シート_v2.xlsx の「製品リスト(日)/(英)」シートに
//! 事業・カテゴリ・サブカテゴリの3段連動プルダウンを埋め込むモジュール。
//!
//! 実装は Python の openpyxl を使用し、このクレートに埋め込まれたスクリプトを
//! 一時ファイルに展開して実行する。
//!
//! Python 3.9 以上と openpyxl 3.x が必要。

use std::path::{Path, PathBuf};

use crate::config::Config;

/// inject_dropdown.py のソースコード（バイナリに埋め込む）
const INJECT_SCRIPT: &str = include_str!("inject_dropdown.py");

#[derive(Debug, thiserror::Error)]
pub enum DropdownError {
    #[error("ファイルの読み込みに失敗しました: {0}")]
    Io(#[from] std::io::Error),
    #[error("Python スクリプトの実行に失敗しました: {0}")]
    PythonFailed(String),
    #[error("Python 3 が見つかりませんでした。python3 または python をインストールしてください。")]
    PythonNotFound,
    #[error("カテゴリ設定の JSON 変換に失敗しました: {0}")]
    JsonError(#[from] serde_json::Error),
}

/// カテゴリ設定を JSON に変換するための中間型
#[derive(serde::Serialize)]
struct CategoryAreaJson<'a> {
    lang: &'a str,
    area: &'a str,
    categories: Vec<CategoryEntryJson<'a>>,
}

#[derive(serde::Serialize)]
struct CategoryEntryJson<'a> {
    name: &'a str,
    sub_categories: &'a [String],
}

/// カテゴリ設定を JSON 文字列に変換する。
fn build_config_json(cfg: &Config) -> Result<String, DropdownError> {
    let mut entries: Vec<CategoryAreaJson> = Vec::new();

    for area in cfg.product_categories.iter() {
        entries.push(CategoryAreaJson {
            lang: &area.lang,
            area: &area.area,
            categories: area
                .categories
                .iter()
                .map(|c| CategoryEntryJson {
                    name: &c.name,
                    sub_categories: &c.sub_categories,
                })
                .collect(),
        });
    }

    Ok(serde_json::to_string(&entries)?)
}

/// Python インタープリタのパスを探す。
fn find_python() -> Option<&'static str> {
    for cmd in &["python3", "python"] {
        if std::process::Command::new(cmd)
            .arg("--version")
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .status()
            .map(|s| s.success())
            .unwrap_or(false)
        {
            return Some(cmd);
        }
    }
    None
}

/// 既存の xlsx ファイルに製品リストシートの3段連動プルダウンを注入する。
///
/// - `input_path`:  元のアドバイザリ入力シート_v2.xlsx
/// - `output_path`: 出力先（None の場合は input_path を上書き）
/// - `cfg`:         secAdvisoryTool.toml の設定（カテゴリマスタ）
pub fn inject_dropdown(
    input_path: &Path,
    output_path: Option<&Path>,
    cfg: &Config,
) -> Result<PathBuf, DropdownError> {
    // Python インタープリタを探す
    let python = find_python().ok_or(DropdownError::PythonNotFound)?;

    // カテゴリ設定を JSON に変換
    let config_json = build_config_json(cfg)?;

    // 出力先パスを決定（None の場合は input_path を上書き）
    let out_path = output_path
        .map(|p| p.to_path_buf())
        .unwrap_or_else(|| input_path.to_path_buf());

    if let Some(parent) = out_path.parent() {
        if !parent.as_os_str().is_empty() {
            std::fs::create_dir_all(parent)?;
        }
    }

    // Python スクリプトを一時ファイルに書き出す
    let script_path = {
        let tmp_dir = std::env::temp_dir();
        tmp_dir.join("sec_advisory_inject_dropdown.py")
    };
    std::fs::write(&script_path, INJECT_SCRIPT)?;

    // Python スクリプトを実行
    let output = std::process::Command::new(python)
        .arg("-I")  // isolated mode: sys.path を汚染しない
        .arg(&script_path)
        .arg(input_path)
        .arg(&out_path)
        .arg(&config_json)
        .output()
        .map_err(|e| {
            if e.kind() == std::io::ErrorKind::NotFound {
                DropdownError::PythonNotFound
            } else {
                DropdownError::Io(e)
            }
        })?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr).into_owned();
        let stdout = String::from_utf8_lossy(&output.stdout).into_owned();
        let msg = if !stderr.is_empty() {
            stderr
        } else {
            stdout
        };
        return Err(DropdownError::PythonFailed(msg.trim().to_string()));
    }

    // stdout の "OK:<path>" を確認する（成功の合図）
    let stdout = String::from_utf8_lossy(&output.stdout);
    if !stdout.trim_start().starts_with("OK:") {
        let msg = format!(
            "スクリプトの出力が期待外の形式です: {}",
            stdout.trim()
        );
        return Err(DropdownError::PythonFailed(msg));
    }

    // 一時スクリプトを削除（エラーは無視）
    let _ = std::fs::remove_file(&script_path);

    Ok(out_path)
}
