//! 設定ファイル (`secAdvisoryTool.toml`) の読み込み。
//!
//! 設定ファイルの場所:
//!   1. カレントディレクトリの `secAdvisoryTool.toml`
//!   2. 実行ファイルと同じディレクトリの `secAdvisoryTool.toml`
//!
//! ファイルが存在しない場合はデフォルト値を使用する。
//!
//! ## 設定ファイル例
//! ```toml
//! # JSON ファイルの出力先ルートディレクトリ
//! output_dir = "C:/path/to/vuls.ricoh.com"
//! ```

use std::path::{Path, PathBuf};

use serde::Deserialize;

/// `secAdvisoryTool.toml` の内容。
#[derive(Debug, Default, Deserialize)]
pub struct Config {
    /// JSON ファイルの出力先ルートディレクトリ。
    /// CLI の `--output` オプションで上書き可能。
    pub output_dir: Option<String>,
}

/// 設定ファイルを読み込む。
///
/// 以下の順で探索し、最初に見つかったファイルを読む。
/// - カレントディレクトリの `secAdvisoryTool.toml`
/// - 実行ファイルと同じディレクトリの `secAdvisoryTool.toml`
///
/// どちらも存在しない場合は `Config::default()` を返す。
pub fn load() -> Config {
    // 1. カレントディレクトリ
    if let Ok(cwd) = std::env::current_dir() {
        let p = cwd.join("secAdvisoryTool.toml");
        if let Some(cfg) = try_load(&p) {
            return cfg;
        }
    }
    // 2. 実行ファイルと同じディレクトリ
    if let Ok(exe) = std::env::current_exe() {
        if let Some(dir) = exe.parent() {
            let p = dir.join("secAdvisoryTool.toml");
            if let Some(cfg) = try_load(&p) {
                return cfg;
            }
        }
    }
    Config::default()
}

fn try_load(path: &Path) -> Option<Config> {
    let text = std::fs::read_to_string(path).ok()?;
    toml::from_str(&text).ok()
}

impl Config {
    /// `output_dir` の設定値を `PathBuf` で返す。
    /// 未設定の場合は `None`。
    pub fn output_dir_path(&self) -> Option<PathBuf> {
        self.output_dir.as_deref().map(PathBuf::from)
    }
}
