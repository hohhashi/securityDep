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

// ================================================================
// カテゴリマスタ構造体
// ================================================================

/// `[[product_categories]]` の 1 エントリ（事業単位）。
#[derive(Debug, Clone, Deserialize, Default)]
pub struct ProductCategoryArea {
    /// "ja" または "en"
    pub lang: String,
    /// 事業名（例: "オフィスプロダクツ", "Office Products"）
    pub area: String,
    /// カテゴリ一覧
    #[serde(default)]
    pub categories: Vec<ProductCategoryEntry>,
}

/// カテゴリ 1 件。
#[derive(Debug, Clone, Deserialize, Default)]
pub struct ProductCategoryEntry {
    /// カテゴリ名（例: "デジタル複合機"）
    pub name: String,
    /// サブカテゴリ名一覧（空のカテゴリは空配列）
    #[serde(default)]
    pub sub_categories: Vec<String>,
}

// ================================================================
// Config
// ================================================================

/// `secAdvisoryTool.toml` の内容。
#[derive(Debug, Default, Deserialize)]
pub struct Config {
    /// JSON ファイルの出力先ルートディレクトリ。
    /// CLI の `--output` オプションで上書き可能。
    pub output_dir: Option<String>,

    /// 製品カテゴリマスタ（`[[product_categories]]` 配列）。
    /// 未設定の場合は空。
    #[serde(default)]
    pub product_categories: Vec<ProductCategoryArea>,
}

impl Config {
    /// `output_dir` の設定値を `PathBuf` で返す。
    /// 未設定の場合は `None`。
    pub fn output_dir_path(&self) -> Option<PathBuf> {
        self.output_dir.as_deref().map(PathBuf::from)
    }

    /// 指定言語のカテゴリマスタを返す。
    /// `lang`: "ja" または "en"
    pub fn categories_for_lang(&self, lang: &str) -> Vec<&ProductCategoryArea> {
        self.product_categories
            .iter()
            .filter(|a| a.lang == lang)
            .collect()
    }

    /// 指定言語の事業名一覧を返す（順序保持）。
    pub fn area_names(&self, lang: &str) -> Vec<&str> {
        self.categories_for_lang(lang)
            .iter()
            .map(|a| a.area.as_str())
            .collect()
    }

    /// 指定言語・事業のカテゴリ名一覧を返す（順序保持）。
    pub fn category_names(&self, lang: &str, area: &str) -> Vec<&str> {
        self.categories_for_lang(lang)
            .iter()
            .find(|a| a.area == area)
            .map(|a| a.categories.iter().map(|c| c.name.as_str()).collect())
            .unwrap_or_default()
    }

    /// 指定言語・事業・カテゴリのサブカテゴリ名一覧を返す（順序保持）。
    /// サブカテゴリなしの場合は空。
    pub fn sub_category_names(&self, lang: &str, area: &str, category: &str) -> Vec<&str> {
        self.categories_for_lang(lang)
            .iter()
            .find(|a| a.area == area)
            .and_then(|a| a.categories.iter().find(|c| c.name == category))
            .map(|c| c.sub_categories.iter().map(|s| s.as_str()).collect())
            .unwrap_or_default()
    }
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
