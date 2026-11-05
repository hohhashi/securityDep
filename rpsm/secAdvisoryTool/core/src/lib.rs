//! secadvisory-core v2
//!
//! アドバイザリ入力シート_v2.xlsx を読み込み、
//! ja / en それぞれの JSON ファイルを出力する。

pub mod config;
pub mod excel;
pub mod id_gen;
pub mod model;
pub mod pdf;
pub mod server;
pub mod store;

pub use config::Config;
pub use excel::{
    read_advisory, read_advisory_product_ids, read_product_list, read_published_year,
    AdvisoryOutput, ExcelError,
};
pub use store::{
    delete_doc, export_prodinfolist, read_prodinfolist_prod_ids, remove_advisory_from_prodinfo,
    remove_from_vulinfolist, update_prodinfo_file, update_prodinfolist, update_vulinfolist,
    write_doc, StoreError,
};

use std::path::{Path, PathBuf};

use model::{ProdAdvisoryEntry, ProductListRow, VulnDoc};

#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error(transparent)]
    Excel(#[from] ExcelError),
    #[error(transparent)]
    Store(#[from] StoreError),
    #[error("製品 '{name}' (prod_id: {prod_id}) が prodinfolist.json に存在しません。先に sync-products を実行してください。")]
    ProductNotFound { name: String, prod_id: String },
    #[error("ファイル操作エラー: {0}")]
    Io(#[from] std::io::Error),
}

/// 生成・更新された JSON ファイルのパスと採番された ID を返す。
pub struct RunResult {
    pub id: String,
    /// `vulinfo/{YYYY}/{id}.json` のパス一覧（ja / en）
    pub paths: Vec<PathBuf>,
    /// `vulinfolist.json` のパス一覧（ja / en）
    pub list_paths: Vec<PathBuf>,
    /// `prodinfo/{prod_id}.json` のパス一覧
    pub prod_paths: Vec<PathBuf>,
    /// 生成した PDF ファイルのパス一覧（ja / en）。
    /// PDF 生成をスキップした場合（ブラウザ未検出など）は空。
    pub pdf_paths: Vec<PathBuf>,
}

/// sync-products の結果。
pub struct SyncProductsResult {
    /// 更新した `prodinfolist.json` のパス一覧（ja / en）
    pub list_paths: Vec<PathBuf>,
    /// 処理した ProductListRow の件数
    pub row_count: usize,
}

/// delete の結果。
pub struct DeleteResult {
    pub id: String,
    /// 削除した `vulinfo/{YYYY}/{id}.json` のパス一覧
    pub deleted: Vec<PathBuf>,
    /// 更新した `vulinfolist.json` のパス一覧
    pub updated_lists: Vec<PathBuf>,
    /// 更新した `prodinfo/{prod_id}.json` のパス一覧
    pub updated_prodinfo: Vec<PathBuf>,
}

/// create: Excel を読み込み、ID を自動採番して JSON を出力する。
///
/// - `excel_path` : アドバイザリ入力シート_v2.xlsx のパス
/// - `output_dir` : JSON ファイルの出力先ルートディレクトリ
///
/// TblAdvisoryJa に記載の製品が prodinfolist.json に存在しない場合はエラー。
pub fn run_create(excel_path: &Path, output_dir: &Path) -> Result<RunResult, AppError> {
    let year = read_published_year(excel_path)?;
    let id = id_gen::next_id(output_dir, &year);
    run_inner(excel_path, &id, output_dir)
}

/// update: Excel を読み込み、指定された ID で JSON を上書き出力する。
///
/// - `excel_path` : アドバイザリ入力シート_v2.xlsx のパス
/// - `id`         : 上書き対象の ID（`ricoh-YYYY-NNNNNN` 形式）
/// - `output_dir` : JSON ファイルの出力先ルートディレクトリ
///
/// TblAdvisoryJa に記載の製品が prodinfolist.json に存在しない場合はエラー。
pub fn run_update(excel_path: &Path, id: &str, output_dir: &Path) -> Result<RunResult, AppError> {
    run_inner(excel_path, id, output_dir)
}

/// sync-products: 採番済機種リスト(日)/(英) を読み込み、
/// prodinfolist.json と prodinfo/{prod_id}.json を作成・更新する。
///
/// - `excel_path` : 採番済機種リストを含む Excel ファイルのパス
/// - `output_dir` : JSON ファイルの出力先ルートディレクトリ
pub fn run_sync_products(excel_path: &Path, output_dir: &Path) -> Result<SyncProductsResult, AppError> {
    let all_rows = read_product_list(excel_path)?;
    let row_count = all_rows.len();

    // 言語ごとに分類
    // B列(lang) が "日本語" を含む → ja、"英語" を含む → en
    // 両方含む場合や空欄の場合は ja 扱い
    let ja_rows: Vec<&ProductListRow> = all_rows
        .iter()
        .filter(|r| !r.lang.contains("英語"))
        .collect();
    let en_rows: Vec<&ProductListRow> = all_rows
        .iter()
        .filter(|r| r.lang.contains("英語"))
        .collect();

    let mut list_paths = Vec::new();

    // prodinfolist.json を更新
    if !ja_rows.is_empty() {
        let ja_cloned: Vec<ProductListRow> = ja_rows.iter().map(|r| (*r).clone()).collect();
        list_paths.push(update_prodinfolist(output_dir, "ja", &ja_cloned)?);
    }
    if !en_rows.is_empty() {
        let en_cloned: Vec<ProductListRow> = en_rows.iter().map(|r| (*r).clone()).collect();
        list_paths.push(update_prodinfolist(output_dir, "en", &en_cloned)?);
    }

    Ok(SyncProductsResult { list_paths, row_count })
}

/// export-products: prodinfolist.json の内容を Excel ファイルに出力する。
///
/// - `output_dir` : ja / en サブディレクトリが置かれているルートディレクトリ
/// - `out_path`   : 出力先 .xlsx のパス（None の場合は `{output_dir}/採番済機種リスト_export.xlsx`）
pub fn run_export_products(
    output_dir: &Path,
    out_path: Option<&std::path::Path>,
) -> Result<std::path::PathBuf, AppError> {
    let p = export_prodinfolist(output_dir, out_path)?;
    Ok(p)
}

/// delete: 指定された ID のアドバイザリファイルを削除し、vulinfolist からも除去する。
///
/// - `id`         : 削除対象の ID（`ricoh-YYYY-NNNNNN` 形式）
/// - `output_dir` : JSON ファイルが置かれているルートディレクトリ
/// - `make_gap`   : true のとき gaps.json に ID を記録して欠番扱いにする
pub fn run_delete(id: &str, output_dir: &Path, make_gap: bool) -> Result<DeleteResult, AppError> {
    let mut deleted = Vec::new();
    let mut updated_lists = Vec::new();
    let mut updated_prodinfo = Vec::new();

    for lang in &["ja", "en"] {
        if let Some(p) = delete_doc(output_dir, lang, id)? {
            deleted.push(p);
        }
        if let Some(p) = remove_from_vulinfolist(output_dir, lang, id)? {
            updated_lists.push(p);
        }
        let mut prod_paths = remove_advisory_from_prodinfo(output_dir, lang, id)?;
        updated_prodinfo.append(&mut prod_paths);
    }

    if make_gap {
        id_gen::record_gap(output_dir, id)
            .map_err(|e| AppError::Io(e))?;
    }

    Ok(DeleteResult {
        id: id.to_string(),
        deleted,
        updated_lists,
        updated_prodinfo,
    })
}

fn run_inner(excel_path: &Path, id: &str, output_dir: &Path) -> Result<RunResult, AppError> {
    // --- アドバイザリ JSON 生成（言語判定が必要なのでここで読む） ---
    let output = read_advisory(excel_path, id)?;

    // --- 製品バリデーション ---
    // TblAdvisoryJa / TblAdvisoryEn それぞれから製品リストを取得
    let (ja_pairs, en_pairs) = read_advisory_product_ids(excel_path)?;

    // ja が存在する場合は ja/prodinfolist.json で検証
    if output.ja.is_some() {
        let known = read_prodinfolist_prod_ids(output_dir, "ja")?;
        for (prod_id, prod_name) in &ja_pairs {
            if prod_id.is_empty() {
                return Err(AppError::ProductNotFound {
                    name: prod_name.clone(),
                    prod_id: "(不明)".to_string(),
                });
            }
            if !known.contains(prod_id) {
                return Err(AppError::ProductNotFound {
                    name: prod_name.clone(),
                    prod_id: prod_id.clone(),
                });
            }
        }
    }

    // en が存在する場合は en/prodinfolist.json で検証
    if output.en.is_some() {
        let known = read_prodinfolist_prod_ids(output_dir, "en")?;
        for (prod_id, prod_name) in &en_pairs {
            if prod_id.is_empty() {
                return Err(AppError::ProductNotFound {
                    name: prod_name.clone(),
                    prod_id: "(不明)".to_string(),
                });
            }
            if !known.contains(prod_id) {
                return Err(AppError::ProductNotFound {
                    name: prod_name.clone(),
                    prod_id: prod_id.clone(),
                });
            }
        }
    }

    let mut paths = Vec::new();
    let mut list_paths = Vec::new();
    let mut prod_paths = Vec::new();

    // ja: vulinfo + vulinfolist + ja/prodinfo/ (TblAdvisoryJa の製品)
    if let Some(doc) = &output.ja {
        paths.push(write_doc(output_dir, "ja", doc)?);
        list_paths.push(update_vulinfolist(output_dir, "ja", doc)?);
        for (prod_id, prod_name) in &ja_pairs {
            let entry = build_prod_advisory_entry(id, doc);
            let p = update_prodinfo_file(output_dir, "ja", prod_id, prod_name, entry)?;
            prod_paths.push(p);
        }
    }

    // en: vulinfo + vulinfolist + en/prodinfo/ (TblAdvisoryEn の製品)
    if let Some(doc) = &output.en {
        paths.push(write_doc(output_dir, "en", doc)?);
        list_paths.push(update_vulinfolist(output_dir, "en", doc)?);
        for (prod_id, prod_name) in &en_pairs {
            let entry = build_prod_advisory_entry(id, doc);
            let p = update_prodinfo_file(output_dir, "en", prod_id, prod_name, entry)?;
            if !prod_paths.contains(&p) {
                prod_paths.push(p);
            }
        }
    }

    // --- PDF 生成 ---
    // ローカルHTTPサーバーを起動し、言語ごとにヘッドレスブラウザで PDF 化する。
    // ブラウザが見つからない / 生成に失敗してもエラーにせず警告だけ出す。
    let pdf_paths = generate_pdfs(output_dir, id, &paths);

    Ok(RunResult {
        id: id.to_string(),
        paths,
        list_paths,
        prod_paths,
        pdf_paths,
    })
}

/// 言語ごとに PDF を生成し、生成できたパスの一覧を返す。
/// エラーは stderr に警告として出力し、戻り値には含めない。
fn generate_pdfs(output_dir: &Path, id: &str, json_paths: &[PathBuf]) -> Vec<PathBuf> {
    if json_paths.is_empty() {
        return Vec::new();
    }

    // ローカルサーバーを起動（1回だけ）
    let srv = match server::PdfServer::start(output_dir.to_path_buf()) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("警告: PDF サーバーの起動に失敗しました: {}", e);
            return Vec::new();
        }
    };

    let timestamp = chrono::Local::now().format("%Y%m%d_%H%M%S");
    let mut pdf_paths = Vec::new();

    // json_paths は "ja" と "en" それぞれの JSON パスなので、
    // パスから lang を取り出す（output_dir/{lang}/vulinfo/...）
    for json_path in json_paths {
        // output_dir を除いたパスの先頭ディレクトリが lang
        let rel = json_path.strip_prefix(output_dir).unwrap_or(json_path);
        let lang = rel
            .components()
            .next()
            .and_then(|c| c.as_os_str().to_str())
            .unwrap_or("ja");

        let url = srv.detail_url(lang, id);
        let pdf_name = format!("{}_{}_{}.pdf", id, lang, timestamp);
        // PDF はカレントディレクトリに出力する（output_dir は JSON 専用）
        let pdf_path = std::env::current_dir()
            .unwrap_or_else(|_| std::path::PathBuf::from("."))
            .join(&pdf_name);

        match pdf::render_url_to_pdf(&url, &pdf_path, 4000) {
            Ok(()) => {
                pdf_paths.push(pdf_path);
            }
            Err(e) => {
                eprintln!("警告: PDF 生成に失敗しました ({}): {}", lang, e);
            }
        }
    }

    srv.stop();
    pdf_paths
}

/// アドバイザリ情報から ProdAdvisoryEntry を組み立てる。
/// id は `ricoh-YYYY-NNNNNN` 形式（グローバルアドバイザリ ID）。
fn build_prod_advisory_entry(advisory_id: &str, doc: &VulnDoc) -> ProdAdvisoryEntry {
    use crate::model::VulinfoRef;
    ProdAdvisoryEntry {
        id: advisory_id.to_string(),
        title: doc.title.clone(),
        importance: String::new(), // 入力シートに対応フィールドなし
        severity: doc.severity.clone(),
        cve: doc.cve_list.iter().map(|c| VulinfoRef { id: c.id.clone(), url: c.url.clone() }).collect(),
        jvn: doc.jvn.iter().map(|j| VulinfoRef { id: j.id.clone(), url: j.url.clone() }).collect(),
        published_at: doc.published_at.clone(),
        updated_at: doc.updated_at.clone(),
    }
}
