//! v2 JSON スキーマに対応するデータモデル。
//! ja / en それぞれ別ファイルとして出力する。

use serde::{Deserialize, Serialize};

// ---- 共通小型構造体 ----

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CweItem {
    pub id: String,
    pub url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CveItem {
    pub id: String,
    pub label: String,
    pub url: String,
    pub cwe: Vec<CweItem>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JvnItem {
    pub id: String,
    pub url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoryItem {
    #[serde(rename = "updatedAt")]
    pub updated_at: String,
    pub version: String,
    pub company: String,
    pub changes: String,
}

// ---- productStatus ----

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VersionRow {
    pub component: String,
    pub version: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VersionGroup {
    pub group: Option<String>,
    pub rows: Vec<VersionRow>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VersionCheck {
    pub text: String,
    pub url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CountermeasureLink {
    pub text: String,
    pub url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Countermeasure {
    pub text: String,
    pub links: Vec<CountermeasureLink>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NoteItem {
    pub text: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Product {
    pub name: String,
    pub versions: Vec<VersionGroup>,
    #[serde(rename = "versionCheck")]
    pub version_check: VersionCheck,
    pub countermeasure: Countermeasure,
    pub notes: Vec<NoteItem>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProductStatus {
    #[serde(rename = "businessFields")]
    pub business_fields: Vec<serde_json::Value>,
    #[serde(rename = "list2Title")]
    pub list2_title: String,
    pub products: Vec<Product>,
}

// ---- contact ----

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContactLink {
    pub text: String,
    pub url: String,
    #[serde(rename = "imageUrl", skip_serializing_if = "String::is_empty")]
    pub image_url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Contact {
    pub text: String,
    pub links: Vec<ContactLink>,
}

// ---- vulinfolist.json エントリ ----

// ---- prodinfolist.json ----

/// `{lang}/prodinfolist.json` の最上位配列要素（事業単位）。
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProdInfoArea {
    pub name: String,
    pub categories: Vec<ProdInfoCategory>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProdInfoCategory {
    pub name: String,
    #[serde(rename = "subCategories")]
    pub sub_categories: Vec<ProdInfoSubCategory>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProdInfoSubCategory {
    pub name: String,
    pub products: Vec<ProdInfoProduct>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProdInfoProduct {
    pub name: String,
    pub id: String,
}

// ---- prodXXX.json ----

/// `{lang}/prodinfo/{prod_id}.json` のトップレベル。
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProdInfoFile {
    /// フォーマットバージョン（旧ファイルにはない場合があるため default = ""）
    #[serde(default)]
    pub version: String,
    /// 製品名（prodinfolist から引く）
    pub name: String,
    /// prod_id（例: "prod000020"）
    pub id: String,
    /// この製品に関係するアドバイザリ一覧
    pub advisories: Vec<ProdAdvisoryEntry>,
}

/// `prodXXX.json` の advisories 配列の 1 要素。
/// id は `ricoh-YYYY-NNNNNN` 形式（グローバルアドバイザリ ID）。
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProdAdvisoryEntry {
    pub id: String,
    pub title: String,
    /// 重要度（旧ファイルにはない場合があるため default = ""）
    #[serde(default)]
    pub importance: String,
    /// CVSS スコア文字列（旧ファイルにはない場合があるため default = ""）
    #[serde(default)]
    pub severity: String,
    /// CVE ID / URL ペアの配列（旧ファイルにはない場合があるため default = []）
    #[serde(default)]
    pub cve: Vec<VulinfoRef>,
    /// JVN 登録番号 / URL ペアの配列（旧ファイルにはない場合があるため default = []）
    #[serde(default)]
    pub jvn: Vec<VulinfoRef>,
    /// 公開日（RFC3339 形式、旧ファイルにはない場合があるため default = ""）
    #[serde(rename = "publishedAt", default)]
    pub published_at: String,
    /// 最終更新日（RFC3339 形式、旧ファイルにはない場合があるため default = ""）
    #[serde(rename = "updatedAt", default)]
    pub updated_at: String,
}

// ---- 製品リスト 1 行分 ----

/// 製品リスト(日)/(英) の 1 行分。
/// prod_id は prodinfolist.json 側のみで管理する。
/// Excel（テンプレート・export-products 出力とも）には prod_id 列を持たない。
/// 製品の同一性は (lang, area, category, sub_category, product_name) の複合キーで判定する。
#[derive(Debug, Clone)]
pub struct ProductListRow {
    pub lang: String,         // "日本語" or "英語"
    pub area: String,         // 事業
    pub category: String,     // カテゴリ
    pub sub_category: String, // サブカテゴリ
    pub product_name: String, // 製品・サービス名
    pub dev_name: String,     // 補足（開発名など）: 参考情報のみ、処理には使わない
}

/// `{lang}/vulinfolist.json` の1件分のエントリ。
/// アドバイザリ一覧画面で使用する。
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VulinfoEntry {
    pub id: String,
    pub title: String,
    pub importance: String,
    pub severity: String,
    /// CVE の id / url ペアの配列
    pub cve: Vec<VulinfoRef>,
    /// JVN の id / url ペアの配列
    pub jvn: Vec<VulinfoRef>,
    #[serde(rename = "publishedAt")]
    pub published_at: String,
    #[serde(rename = "updatedAt")]
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VulinfoRef {
    pub id: String,
    pub url: String,
}

// ---- トップレベル ----

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VulnDoc {
    #[serde(rename = "docVersion")]
    pub doc_version: String,
    pub id: String,
    pub title: String,
    pub company: String,
    #[serde(rename = "publishedAt")]
    pub published_at: String,
    #[serde(rename = "updatedAt")]
    pub updated_at: String,
    pub version: String,
    #[serde(rename = "cveList")]
    pub cve_list: Vec<CveItem>,
    pub cvss: String,
    pub severity: String,
    pub jvn: Vec<JvnItem>,
    pub status: String,
    pub impact: Option<String>,
    pub caution: Option<String>,
    #[serde(rename = "interimMeasure")]
    pub interim_measure: Option<String>,
    #[serde(rename = "permanentMeasure")]
    pub permanent_measure: Option<String>,
    #[serde(rename = "investigatingNote")]
    pub investigating_note: Option<String>,
    #[serde(rename = "productStatus")]
    pub product_status: ProductStatus,
    pub contact: Contact,
    pub thanks: String,
    pub history: Vec<HistoryItem>,
    pub url: String,
    #[serde(rename = "authenticityGuarantee")]
    pub authenticity_guarantee: String,
}
