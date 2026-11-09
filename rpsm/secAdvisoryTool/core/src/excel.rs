//! アドバイザリ入力シート_v2.xlsx を読み込み、ja / en それぞれの VulnDoc を返すモジュール。
//!
//! 読み取るテーブル名:
//!   TblVulInfo      (脆弱性セキュリティ情報シート・メイン縦持ちテーブル)
//!   TblCveList      (CVEリスト)
//!   TblJvnList      (JVNリスト)
//!   TblVulHistory   (更新履歴)
//!   TblAdvisoryJa   (アドバイザリ単票(日) メイン)
//!   TblVersionJa    (アドバイザリ単票(日) バージョン情報)
//!   TblNotesJa      (アドバイザリ単票(日) 特記事項)
//!   TblAdvisoryEn   (アドバイザリ単票(英) メイン)
//!   TblVersionEn    (アドバイザリ単票(英) バージョン情報)
//!   TblNotesEn      (アドバイザリ単票(英) 特記事項)

use std::collections::HashMap;
use std::path::Path;

use calamine::{open_workbook, Data, Reader, Xlsx};

use crate::model::{
    CveItem, CweItem, Contact, ContactLink, Countermeasure, CountermeasureLink,
    HistoryItem, JvnItem, NoteItem, Product, ProductListRow, ProductStatus,
    VulnDoc, VersionCheck, VersionGroup, VersionRow,
};

// ---- エラー ----

#[derive(Debug, thiserror::Error)]
pub enum ExcelError {
    #[error("Excelファイルを開けませんでした: {0}")]
    Open(String),
    #[error("テーブル定義の読み込みに失敗しました: {0}")]
    LoadTables(String),
    #[error("テーブル '{0}' が見つかりませんでした")]
    TableNotFound(String),
    #[error("TblVulInfo に項目 '{0}' が見つかりませんでした")]
    MissingItem(String),
    #[error("言語設定が不正です（'日本語のみ'/'英語のみ'/'日本語/英語' のいずれかを指定してください）: {0}")]
    InvalidLang(String),
}

// ---- テーブル読み取り共通 ----

type RowMap = HashMap<String, String>;

fn read_table_rows(workbook_path: &Path, table_name: &str) -> Result<Vec<RowMap>, ExcelError> {
    let mut workbook: Xlsx<_> = open_workbook(workbook_path)
        .map_err(|e| ExcelError::Open(format!("{}: {}", workbook_path.display(), e)))?;
    workbook
        .load_tables()
        .map_err(|e| ExcelError::LoadTables(e.to_string()))?;
    let table = workbook
        .table_by_name(table_name)
        .map_err(|_| ExcelError::TableNotFound(table_name.to_string()))?;

    let columns = table.columns().to_vec();
    let data = table.data();

    let mut rows = Vec::new();
    for row in data.rows() {
        let mut map = RowMap::new();
        let mut all_empty = true;
        for (i, col_name) in columns.iter().enumerate() {
            let value = row.get(i).map(cell_to_string).unwrap_or_default();
            if !value.trim().is_empty() {
                all_empty = false;
            }
            map.insert(col_name.clone(), value);
        }
        if !all_empty {
            rows.push(map);
        }
    }
    Ok(rows)
}

fn cell_to_string(cell: &Data) -> String {
    match cell {
        Data::Empty => String::new(),
        Data::String(s) => s.trim().to_string(),
        Data::Float(f) => {
            if f.fract() == 0.0 { format!("{}", *f as i64) } else { f.to_string() }
        }
        Data::Int(i) => i.to_string(),
        Data::Bool(b) => b.to_string(),
        Data::DateTime(dt) => dt.to_string(),
        Data::DateTimeIso(s) => s.clone(),
        Data::DurationIso(s) => s.clone(),
        Data::Error(e) => format!("{:?}", e),
    }
}

fn get(row: &RowMap, key: &str) -> String {
    row.get(key).map(|s| s.trim().to_string()).unwrap_or_default()
}

// ---- TblVulInfo（縦持ち: 項目名→値） ----

/// 縦持ちテーブル TblVulInfo を「項目名 → 入力内容」の HashMap に変換する。
/// 列構成: No. | 分類 | サブ分類 | 項目 | 入力内容 | 入力例 | 補足
fn read_vul_info(path: &Path) -> Result<HashMap<String, String>, ExcelError> {
    let rows = read_table_rows(path, "TblVulInfo")?;
    let mut map = HashMap::new();
    for row in rows {
        let item = get(&row, "項目");
        let val  = get(&row, "入力内容");
        if !item.is_empty() {
            map.insert(item, val);
        }
    }
    Ok(map)
}

fn vul_get<'a>(info: &'a HashMap<String, String>, key: &str) -> Result<&'a str, ExcelError> {
    info.get(key).map(|s| s.as_str()).ok_or_else(|| ExcelError::MissingItem(key.to_string()))
}

fn vul_opt(info: &HashMap<String, String>, key: &str) -> Option<String> {
    let v = info.get(key).map(|s| s.trim().to_string()).unwrap_or_default();
    if v.is_empty() { None } else { Some(v) }
}

/// テキストを `<p>…</p>` で包む（空の場合は None）。
fn wrap_p(s: &str) -> Option<String> {
    let s = s.trim();
    if s.is_empty() { None } else { Some(format!("<p>{}</p>", s)) }
}

/// "YYYY-MM-DD HH:MM:SS+09:00" → "YYYY-MM-DDTHH:MM:SS+09:00"（ISO8601）
fn to_iso(s: &str) -> String {
    let s = s.trim();
    if s.is_empty() { return String::new(); }
    // スペース区切りをTに変換
    let s = s.replacen(' ', "T", 1);
    // +09:00 なしなら補う
    if s.contains('+') || s.ends_with('Z') { s } else { format!("{}+09:00", s) }
}

// ---- CVE / JVN ----

fn read_cve_list(path: &Path) -> Result<Vec<CveItem>, ExcelError> {
    let rows = read_table_rows(path, "TblCveList")?;
    let mut items = Vec::new();
    for row in &rows {
        let id = get(row, "CVE ID");
        if id.is_empty() || id.starts_with('（') || id.starts_with('(') { continue; }
        let cwe_id  = get(row, "CWE ID");
        let label   = get(row, "ラベル(日)");
        let cwe = if cwe_id.is_empty() {
            vec![]
        } else {
            let num = cwe_id.trim_start_matches("CWE-");
            vec![CweItem {
                id: cwe_id.clone(),
                url: format!("https://cwe.mitre.org/data/definitions/{}.html", num),
            }]
        };
        items.push(CveItem {
            url: format!("https://nvd.nist.gov/vuln/detail/{}", id),
            id,
            label,
            cwe,
        });
    }
    Ok(items)
}

fn read_jvn_list(path: &Path) -> Result<Vec<JvnItem>, ExcelError> {
    let rows = read_table_rows(path, "TblJvnList")?;
    let mut items = Vec::new();
    for row in &rows {
        let id = get(row, "JVN ID");
        if id.is_empty() || id.starts_with('（') || id.starts_with('(') { continue; }
        let url = get(row, "URL");
        items.push(JvnItem { id, url });
    }
    Ok(items)
}

// ---- 更新履歴 ----

fn read_history(path: &Path, company: &str, suffix: &str) -> Result<Vec<HistoryItem>, ExcelError> {
    let rows = read_table_rows(path, "TblVulHistory")?;
    let mut items = Vec::new();
    for row in &rows {
        let ver = get(row, "バージョン");
        if ver.is_empty() || ver.starts_with('（') || ver.starts_with('(') { continue; }
        // バージョン文字列の末尾に suffix (J/E) を付与
        let version = if ver.ends_with('J') || ver.ends_with('E') {
            ver
        } else {
            format!("{}{}", ver, suffix)
        };
        items.push(HistoryItem {
            updated_at: to_iso(&get(row, "更新日時")),
            version,
            company: company.to_string(),
            changes: get(row, "変更内容"),
        });
    }
    Ok(items)
}

// ---- アドバイザリ単票：製品リスト組み立て ----

/// TblAdvisory{lang} を読んで製品マスタ（No→Product）を組み立てる（versionsは後から追加）。
fn read_advisory_products(path: &Path, tbl_name: &str) -> Result<Vec<(u32, Product)>, ExcelError> {
    let rows = read_table_rows(path, tbl_name)?;
    let mut products: Vec<(u32, Product)> = Vec::new();

    for row in &rows {
        let no_str = get(row, "No.");
        if no_str.is_empty() || no_str.starts_with('(') || no_str.starts_with('（') { continue; }
        let no: u32 = no_str.parse().unwrap_or(0);
        if no == 0 { continue; }

        // 既に同じ No. があればスキップ（例行除外後の重複は起こらないはずだが念のため）
        if products.iter().any(|(n, _)| *n == no) { continue; }

        let countermeasure_text = get(row, "恒久対応策テキスト");
        let link_text = get(row, "対応策リンクテキスト");
        let link_url  = get(row, "対応策リンクURL");

        let links = if link_text.is_empty() && link_url.is_empty() {
            vec![]
        } else {
            vec![CountermeasureLink { text: link_text, url: link_url }]
        };

        products.push((no, Product {
            name: get(row, "製品・サービス名"),
            versions: vec![],   // 後で埋める
            version_check: VersionCheck {
                text: get(row, "バージョン確認方法テキスト"),
                url:  get(row, "バージョン確認方法URL"),
            },
            countermeasure: Countermeasure {
                text: if countermeasure_text.is_empty() {
                    String::new()
                } else {
                    format!("<p>{}</p>", countermeasure_text)
                },
                links,
            },
            notes: vec![],      // 後で埋める
        }));
    }
    Ok(products)
}

/// TblVersion{lang} を読んで (no, VersionGroup 行リスト) を返す。
/// 同じ No. / グループ名が連続する行を group にまとめる。
fn read_version_groups(path: &Path, tbl_name: &str) -> Result<Vec<(u32, Vec<VersionGroup>)>, ExcelError> {
    let rows = read_table_rows(path, tbl_name)?;

    // (no, group_name, component, version) に展開
    struct RawRow { no: u32, group: String, component: String, version: String }
    let mut raw: Vec<RawRow> = Vec::new();
    let mut last_no: u32 = 0;

    for row in &rows {
        let no_str = get(row, "No.");
        let no = if no_str.is_empty() {
            last_no
        } else if no_str.starts_with('(') || no_str.starts_with('（') {
            continue;
        } else {
            no_str.parse().unwrap_or(last_no)
        };
        if no == 0 { continue; }
        last_no = no;

        raw.push(RawRow {
            no,
            group: get(row, "グループ名"),
            component: get(row, "構成要素"),
            version: get(row, "バージョン条件"),
        });
    }

    // No. ごとにグループ化
    let mut by_no: Vec<(u32, Vec<VersionGroup>)> = Vec::new();
    for r in raw {
        // 対応する No. のエントリを探す or 追加
        let entry = match by_no.iter_mut().find(|(n, _)| *n == r.no) {
            Some(e) => e,
            None => {
                by_no.push((r.no, vec![]));
                by_no.last_mut().unwrap()
            }
        };
        let groups = &mut entry.1;

        // 同じグループ名があれば row を追加（重複行はスキップ）、なければ新グループ
        let group_opt = if r.group.is_empty() { None } else { Some(r.group.clone()) };
        let new_row = VersionRow { component: r.component, version: r.version };
        match groups.iter_mut().find(|g| g.group == group_opt) {
            Some(g) => {
                // 同一 component+version の重複行はスキップ
                if !g.rows.iter().any(|row| row.component == new_row.component && row.version == new_row.version) {
                    g.rows.push(new_row);
                }
            }
            None => groups.push(VersionGroup {
                group: group_opt,
                rows: vec![new_row],
            }),
        }
    }
    Ok(by_no)
}

/// TblNotes{lang} を読んで (no, Vec<NoteItem>) を返す。
fn read_notes(path: &Path, tbl_name: &str) -> Result<Vec<(u32, Vec<NoteItem>)>, ExcelError> {
    let rows = read_table_rows(path, tbl_name)?;
    let mut by_no: Vec<(u32, Vec<NoteItem>)> = Vec::new();
    let mut last_no: u32 = 0;

    for row in &rows {
        let no_str = get(row, "No.");
        let no = if no_str.is_empty() {
            last_no
        } else if no_str.starts_with('(') || no_str.starts_with('（') {
            continue;
        } else {
            no_str.parse().unwrap_or(last_no)
        };
        if no == 0 { continue; }
        last_no = no;

        let text = get(row, "特記事項");
        if text.is_empty() { continue; }

        match by_no.iter_mut().find(|(n, _)| *n == no) {
            Some(e) => {
                // 同一テキストの重複はスキップ
                if !e.1.iter().any(|n| n.text == text) {
                    e.1.push(NoteItem { text });
                }
            }
            None => by_no.push((no, vec![NoteItem { text }])),
        }
    }
    Ok(by_no)
}

/// 製品リスト・バージョン・特記事項を結合して Vec<Product> を返す。
fn build_products(
    path: &Path,
    adv_tbl: &str,
    ver_tbl: &str,
    notes_tbl: &str,
) -> Result<Vec<Product>, ExcelError> {
    let mut products = read_advisory_products(path, adv_tbl)?;
    let versions = read_version_groups(path, ver_tbl)?;
    let notes    = read_notes(path, notes_tbl)?;

    for (no, prod) in &mut products {
        if let Some((_, vgs)) = versions.iter().find(|(n, _)| n == no) {
            prod.versions = vgs.clone();
        }
        if let Some((_, ns)) = notes.iter().find(|(n, _)| n == no) {
            prod.notes = ns.clone();
        }
    }
    Ok(products.into_iter().map(|(_, p)| p).collect())
}

// ---- 言語判定 ----

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Lang { Ja, En, Both }

impl Lang {
    fn parse(s: &str) -> Result<Self, ExcelError> {
        match s.trim() {
            "日本語のみ" => Ok(Lang::Ja),
            "英語のみ"   => Ok(Lang::En),
            "日本語/英語" | "日本語・英語" => Ok(Lang::Both),
            other => Err(ExcelError::InvalidLang(other.to_string())),
        }
    }
    pub fn has_ja(self) -> bool { matches!(self, Lang::Ja | Lang::Both) }
    pub fn has_en(self) -> bool { matches!(self, Lang::En | Lang::Both) }
}

// ---- 公開エントリポイント ----

pub struct AdvisoryOutput {
    pub lang: Lang,
    pub ja: Option<VulnDoc>,
    pub en: Option<VulnDoc>,
}

pub fn read_advisory(excel_path: &Path, id: &str) -> Result<AdvisoryOutput, ExcelError> {
    let info     = read_vul_info(excel_path)?;
    let cve_list = read_cve_list(excel_path)?;
    let jvn_list = read_jvn_list(excel_path)?;

    let lang_str = vul_get(&info, "言語")?;
    let lang = Lang::parse(lang_str)?;

    let cvss     = vul_opt(&info, "CVSSv3スコア（基本値）").unwrap_or_default();
    let severity = cvss_to_severity(&cvss);
    let status   = map_status(vul_opt(&info, "全体的調査・対応状況").unwrap_or_default().as_str());
    let published_at = to_iso(vul_opt(&info, "公開日時").unwrap_or_default().as_str());

    // 更新日時は更新履歴の最新行から取得
    let ja_doc = if lang.has_ja() {
        let company_ja = vul_opt(&info, "発行元会社名(日)").unwrap_or_default();
        let history_ja = read_history(excel_path, &company_ja, "J")?;
        let updated_at = history_ja.first().map(|h| h.updated_at.clone()).unwrap_or_else(|| published_at.clone());
        let version_ja = history_ja.first().map(|h| h.version.clone()).unwrap_or_default();
        let products_ja = build_products(excel_path, "TblAdvisoryJa", "TblVersionJa", "TblNotesJa")?;

        let contact_ja = {
            let link_text  = vul_opt(&info, "お問い合わせ先 リンクテキスト(日)").unwrap_or_default();
            let link_url   = vul_opt(&info, "お問い合わせ先 リンクURL(日)").unwrap_or_default();
            let image_url  = vul_opt(&info, "お問い合わせ先 画像URL(日)").unwrap_or_default();
            let links = if link_text.is_empty() && link_url.is_empty() { vec![] }
                        else { vec![ContactLink { text: link_text, url: link_url, image_url }] };
            Contact {
                text:  vul_opt(&info, "お問い合わせ先 テキスト(日)").unwrap_or_default(),
                links,
            }
        };

        Some(VulnDoc {
            doc_version: "2.0".to_string(),
            id: id.to_string(),
            title: vul_opt(&info, "タイトル(日)").unwrap_or_default(),
            company: company_ja.clone(),
            published_at: published_at.clone(),
            updated_at,
            version: version_ja,
            cve_list: cve_list.clone(),
            cvss: cvss.clone(),
            severity: severity.clone(),
            jvn: jvn_list.clone(),
            status: status.clone(),
            impact:             wrap_p(&vul_opt(&info, "影響(日)").unwrap_or_default()),
            caution:            wrap_p(&vul_opt(&info, "注意事項(日)").unwrap_or_default()),
            interim_measure:    wrap_p(&vul_opt(&info, "暫定対応策(日)").unwrap_or_default()),
            permanent_measure:  wrap_p(&vul_opt(&info, "恒久対応策(日)").unwrap_or_default()),
            investigating_note: wrap_p(&vul_opt(&info, "調査中注記(日)").unwrap_or_default()),
            product_status: ProductStatus {
                business_fields: vec![],
                list2_title: format!("表1.{}", vul_opt(&info, "表1のタイトル名(日)").unwrap_or_default()),
                products: products_ja,
            },
            contact: contact_ja,
            thanks: vul_opt(&info, "謝辞(日)").unwrap_or_default(),
            history: history_ja,
            url: format!("https://jp.ricoh.com/security/products/vulnerabilities/vul?id={}", id),
            authenticity_guarantee: "このURLリンク先と内容の異なる、あるいはURLを省略した、このドキュメントのテキストのコピーは、重要な情報の欠落や誤りの可能性がありますのでご注意ください。".to_string(),
        })
    } else {
        None
    };

    let en_doc = if lang.has_en() {
        let company_en = vul_opt(&info, "発行元会社名(英)").unwrap_or_default();
        let history_en = read_history(excel_path, &company_en, "E")?;
        let updated_at = history_en.first().map(|h| h.updated_at.clone()).unwrap_or_else(|| published_at.clone());
        let version_en = history_en.first().map(|h| h.version.clone()).unwrap_or_default();
        let products_en = build_products(excel_path, "TblAdvisoryEn", "TblVersionEn", "TblNotesEn")?;

        let contact_en = {
            let link_text  = vul_opt(&info, "お問い合わせ先 リンクテキスト(英)").unwrap_or_default();
            let link_url   = vul_opt(&info, "お問い合わせ先 リンクURL(英)").unwrap_or_default();
            let image_url  = vul_opt(&info, "お問い合わせ先 画像URL(英)").unwrap_or_default();
            let links = if link_text.is_empty() && link_url.is_empty() { vec![] }
                        else { vec![ContactLink { text: link_text, url: link_url, image_url }] };
            Contact {
                text:  vul_opt(&info, "お問い合わせ先 テキスト(英)").unwrap_or_default(),
                links,
            }
        };

        Some(VulnDoc {
            doc_version: "2.0".to_string(),
            id: id.to_string(),
            title: vul_opt(&info, "タイトル(英)").unwrap_or_default(),
            company: company_en.clone(),
            published_at: published_at.clone(),
            updated_at,
            version: version_en,
            cve_list: cve_list.clone(),
            cvss: cvss.clone(),
            severity: severity.clone(),
            jvn: jvn_list.clone(),
            status: status.clone(),
            impact:             wrap_p(&vul_opt(&info, "影響(英)").unwrap_or_default()),
            caution:            wrap_p(&vul_opt(&info, "注意事項(英)").unwrap_or_default()),
            interim_measure:    wrap_p(&vul_opt(&info, "暫定対応策(英)").unwrap_or_default()),
            permanent_measure:  wrap_p(&vul_opt(&info, "恒久対応策(英)").unwrap_or_default()),
            investigating_note: wrap_p(&vul_opt(&info, "調査中注記(英)").unwrap_or_default()),
            product_status: ProductStatus {
                business_fields: vec![],
                list2_title: format!("List1:{}", vul_opt(&info, "表1のタイトル名(英)").unwrap_or_default()),
                products: products_en,
            },
            contact: contact_en,
            thanks: vul_opt(&info, "謝辞(英)").unwrap_or_default(),
            history: history_en,
            url: format!("https://www.ricoh.com/products/security/vulnerabilities/vul?id={}", id),
            authenticity_guarantee: "Please note that any copy or paraphrase of the text of this document that differs in content from the distribution URL link, or omits the URL, is an uncontrolled copy and may lack important information or contain factual errors.".to_string(),
        })
    } else {
        None
    };

    Ok(AdvisoryOutput { lang, ja: ja_doc, en: en_doc })
}

fn cvss_to_severity(cvss: &str) -> String {
    let score: f64 = cvss.trim().parse().unwrap_or(0.0);
    match score {
        s if s == 0.0          => "NONE".to_string(),
        s if s < 4.0           => "LOW".to_string(),
        s if s < 7.0           => "MEDIUM".to_string(),
        s if s < 9.0           => "HIGH".to_string(),
        _                      => "CRITICAL".to_string(),
    }
}

fn map_status(s: &str) -> String {
    match s.trim() {
        "調査済" => "confirmed".to_string(),
        "調査中" => "investigating".to_string(),
        "影響なし" => "not-affected".to_string(),
        other => other.to_string(),
    }
}

/// TblVulInfo の「公開日時」だけを読み取り、先頭4文字（YYYY）を返す。
/// create 時に採番用の年を取得するために使う。
pub fn read_published_year(excel_path: &Path) -> Result<String, ExcelError> {
    let info = read_vul_info(excel_path)?;
    let published_at = to_iso(vul_opt(&info, "公開日時").unwrap_or_default().as_str());
    if published_at.len() >= 4 {
        Ok(published_at[..4].to_string())
    } else {
        Err(ExcelError::MissingItem("公開日時".to_string()))
    }
}

/// 製品リスト(日) / 製品リスト(英) を読み取り、ProductListRow の Vec を返す。
///
/// 列構成（テンプレート・export-products 出力とも同じ）:
///   A=言語  B=事業  C=カテゴリ  D=サブカテゴリ  E=製品・サービス名  F=補足（参考・非表示）
///
/// prod_id 列は存在しない。製品の同一性は複合キーで管理する。
/// ヘッダー行は A列が "言語" / "Language" なのでスキップ。
/// 存在しないシートはスキップする。
pub fn read_product_list(excel_path: &Path) -> Result<Vec<ProductListRow>, ExcelError> {
    let mut rows: Vec<ProductListRow> = Vec::new();

    for sheet_name in &["製品リスト(日)", "製品リスト(英)"] {
        let sheet_rows = match read_raw_sheet(excel_path, sheet_name) {
            Ok(r) => r,
            Err(ExcelError::TableNotFound(_)) => continue, // シートが無ければスキップ
            Err(e) => return Err(e),
        };

        for row in sheet_rows {
            // A列(インデックス0)で言語を判定。ヘッダー行はスキップ
            let lang_cell = row.get(0).cloned().unwrap_or_default();
            if lang_cell == "言語" || lang_cell == "Language" || lang_cell.is_empty() {
                continue;
            }
            let product_name = row.get(4).cloned().unwrap_or_default();
            if product_name.is_empty() {
                continue;
            }
            rows.push(ProductListRow {
                lang:         lang_cell,
                area:         row.get(1).cloned().unwrap_or_default(),
                category:     row.get(2).cloned().unwrap_or_default(),
                sub_category: row.get(3).cloned().unwrap_or_default(),
                product_name,
                dev_name:     row.get(5).cloned().unwrap_or_default(),
            });
        }
    }

    Ok(rows)
}


/// TblAdvisoryJa / TblAdvisoryEn それぞれの製品名一覧を返す。
///
/// 返り値: (ja_names, en_names) — 各要素は Vec<String>（製品・サービス名）。
/// prod_id の解決は呼び出し側が prodinfolist.json を参照して行う。
pub fn read_advisory_product_names(
    excel_path: &Path,
) -> Result<(Vec<String>, Vec<String>), ExcelError> {
    let ja_names = read_product_names_from_table(excel_path, "TblAdvisoryJa")?;
    let en_names = read_product_names_from_table(excel_path, "TblAdvisoryEn")?;
    Ok((ja_names, en_names))
}

/// TblAdvisory* テーブルから製品名のみ抽出する。
fn read_product_names_from_table(
    excel_path: &Path,
    tbl_name: &str,
) -> Result<Vec<String>, ExcelError> {
    let adv_rows = match read_table_rows(excel_path, tbl_name) {
        Ok(r) => r,
        Err(ExcelError::TableNotFound(_)) => return Ok(Vec::new()),
        Err(e) => return Err(e),
    };
    let mut result = Vec::new();
    for row in &adv_rows {
        let no_str = get(row, "No.");
        if no_str.is_empty() || no_str.starts_with('(') || no_str.starts_with('（') {
            continue;
        }
        let no: u32 = no_str.parse().unwrap_or(0);
        if no == 0 { continue; }
        let product_name = get(row, "製品・サービス名");
        if product_name.is_empty() { continue; }
        result.push(product_name);
    }
    Ok(result)
}

// ---- シート直接読み取り（テーブルなしシート用） ----

/// テーブルではなく生シートを A 列から順に Vec<Vec<String>> で返す。
/// 空行はスキップする。シートが見つからない場合は TableNotFound を返す。
fn read_raw_sheet(workbook_path: &Path, sheet_name: &str) -> Result<Vec<Vec<String>>, ExcelError> {
    let mut workbook: calamine::Xlsx<_> = calamine::open_workbook(workbook_path)
        .map_err(|e| ExcelError::Open(format!("{}: {}", workbook_path.display(), e)))?;

    let range = workbook
        .worksheet_range(sheet_name)
        .map_err(|_| ExcelError::TableNotFound(sheet_name.to_string()))?;

    let mut rows = Vec::new();
    for row in range.rows() {
        let cells: Vec<String> = row.iter().map(cell_to_string).collect();
        let non_empty = cells.iter().any(|s| !s.trim().is_empty());
        if non_empty {
            rows.push(cells);
        }
    }
    Ok(rows)
}
