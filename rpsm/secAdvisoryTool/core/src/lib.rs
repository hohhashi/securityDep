//! secadvisory-core v2
//!
//! アドバイザリ入力シート_v2.xlsx を読み込み、
//! ja / en それぞれの JSON ファイルを出力する。

pub mod config;
pub mod dropdown;
pub mod excel;
pub mod id_gen;
pub mod model;
pub mod pdf;
pub mod server;
pub mod store;

pub use config::Config;
pub use excel::{
    read_advisory, read_advisory_product_names, read_product_list, read_published_year,
    AdvisoryOutput, ExcelError,
};
pub use dropdown::{inject_dropdown, DropdownError};
pub use store::{
    delete_doc, export_prodinfolist, remove_advisory_from_prodinfo,
    remove_from_vulinfolist, replace_prodinfolist, update_prodinfo_file, update_prodinfolist,
    update_vulinfolist, write_doc, StoreError,
};

use std::path::{Path, PathBuf};

use model::{ProdAdvisoryEntry, ProductListRow, VulnDoc};

#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error(transparent)]
    Excel(#[from] ExcelError),
    #[error(transparent)]
    Store(#[from] StoreError),
    #[error(transparent)]
    Dropdown(#[from] DropdownError),
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

/// sync-products: 製品リスト(日)/(英) を読み込み、prodinfolist.json を**完全置換**する。
///
/// - 入力ファイルは `export-products` で出力した Excel（不要行を削除したもの）。
/// - 追加・更新・削除をすべていっぺんに行う（入力にない既存エントリは prodinfolist から消える）。
/// - prodinfo/{prod_id}.json ファイル自体は削除しない（孤立ファイルとして残る）。
/// - ja / en 両言語を同時に処理する。
///
/// - `excel_path` : 製品リストを含む Excel ファイルのパス
/// - `output_dir` : JSON ファイルの出力先ルートディレクトリ
pub fn run_sync_products(excel_path: &Path, output_dir: &Path) -> Result<SyncProductsResult, AppError> {
    let all_rows = read_product_list(excel_path)?;
    let row_count = all_rows.len();

    // 言語ごとに分類
    // B列(lang) が "英語" / "English" を含む → en、それ以外 → ja
    let ja_rows: Vec<ProductListRow> = all_rows.iter()
        .filter(|r| !r.lang.contains("英語") && !r.lang.to_lowercase().contains("english"))
        .cloned()
        .collect();
    let en_rows: Vec<ProductListRow> = all_rows.iter()
        .filter(|r| r.lang.contains("英語") || r.lang.to_lowercase().contains("english"))
        .cloned()
        .collect();

    let mut list_paths = Vec::new();

    // 完全置換（入力行にないエントリは削除される）
    list_paths.push(replace_prodinfolist(output_dir, "ja", &ja_rows)?);
    list_paths.push(replace_prodinfolist(output_dir, "en", &en_rows)?);

    Ok(SyncProductsResult { list_paths, row_count })
}

/// export-products: prodinfolist.json の内容を Excel ファイル（製品リスト_export.xlsx）に出力する。
///
/// カテゴリ・サブカテゴリのドロップダウンはtomlのマスタから生成する。
///
/// - `output_dir` : ja / en サブディレクトリが置かれているルートディレクトリ
/// - `out_path`   : 出力先 .xlsx のパス（None の場合は `{output_dir}/製品リスト_export.xlsx`）
pub fn run_export_products(
    output_dir: &Path,
    out_path: Option<&std::path::Path>,
) -> Result<std::path::PathBuf, AppError> {
    let cfg = config::load();
    let p = export_prodinfolist(output_dir, out_path, &cfg)?;
    Ok(p)
}

/// delete: 指定された ID のアドバイザリファイルを削除し、vulinfolist からも除去する。
///
/// - `id`         : 削除対象の ID（`ricoh-YYYY-NNNNNN` 形式）
/// - `output_dir` : JSON ファイルが置かれているルートディレクトリ
///
/// 削除した ID は欠番扱いにしない（次回の採番で自然に番号が進む）。
pub fn run_delete(id: &str, output_dir: &Path) -> Result<DeleteResult, AppError> {
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

    Ok(DeleteResult {
        id: id.to_string(),
        deleted,
        updated_lists,
        updated_prodinfo,
    })
}

/// update-template: アドバイザリ入力シート_v2.xlsx に連動プルダウンを埋め込む。
///
/// - `input_path`:  元の xlsx テンプレートパス
/// - `output_path`: 出力先（None の場合は input_path を上書き）
pub fn run_update_template(
    input_path: &Path,
    output_path: Option<&Path>,
) -> Result<PathBuf, AppError> {
    let cfg = config::load();
    let out = inject_dropdown(input_path, output_path, &cfg)?;
    Ok(out)
}

fn run_inner(excel_path: &Path, id: &str, output_dir: &Path) -> Result<RunResult, AppError> {
    // --- アドバイザリ JSON 生成 ---
    let output = read_advisory(excel_path, id)?;

    // --- 単票から製品名を取得 ---
    let (ja_names, en_names) = read_advisory_product_names(excel_path)?;

    // --- 製品名 → prod_id の解決（未登録なら prodinfolist に自動追加） ---
    // ja: 製品リスト(日) の行を使って upsert
    let ja_product_rows = make_product_rows_from_names(excel_path, &ja_names, "日本語")?;
    if !ja_product_rows.is_empty() {
        update_prodinfolist(output_dir, "ja", &ja_product_rows)?;
    }
    // en: 製品リスト(英) の行を使って upsert
    let en_product_rows = make_product_rows_from_names(excel_path, &en_names, "英語")?;
    if !en_product_rows.is_empty() {
        update_prodinfolist(output_dir, "en", &en_product_rows)?;
    }

    // --- prodinfolist から prod_id を引く ---
    let ja_pairs = resolve_prod_ids(output_dir, "ja", &ja_names)?;
    let en_pairs = resolve_prod_ids(output_dir, "en", &en_names)?;

    let mut paths = Vec::new();
    let mut list_paths = Vec::new();
    let mut prod_paths = Vec::new();

    // ja: vulinfo + vulinfolist + ja/prodinfo/ (TblAdvisoryJa の製品)
    if let Some(doc) = &output.ja {
        paths.push(write_doc(output_dir, "ja", doc)?);
        if let Some(p) = update_vulinfolist(output_dir, "ja", doc)? {
            list_paths.push(p);
        }
        for (prod_id, prod_name) in &ja_pairs {
            let entry = build_prod_advisory_entry(id, doc);
            if let Some(p) = update_prodinfo_file(output_dir, "ja", prod_id, prod_name, entry)? {
                prod_paths.push(p);
            }
        }
    }

    // en: vulinfo + vulinfolist + en/prodinfo/ (TblAdvisoryEn の製品)
    if let Some(doc) = &output.en {
        paths.push(write_doc(output_dir, "en", doc)?);
        if let Some(p) = update_vulinfolist(output_dir, "en", doc)? {
            list_paths.push(p);
        }
        for (prod_id, prod_name) in &en_pairs {
            let entry = build_prod_advisory_entry(id, doc);
            if let Some(p) = update_prodinfo_file(output_dir, "en", prod_id, prod_name, entry)? {
                if !prod_paths.contains(&p) {
                    prod_paths.push(p);
                }
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
                // Windows の \ を / に統一して返す
                let normalized = PathBuf::from(
                    pdf_path.to_string_lossy().replace('\\', "/")
                );
                pdf_paths.push(normalized);
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
/// 単票に記載された製品名に対応する ProductListRow を製品リストシートから検索して返す。
/// 製品リストシートに存在しない製品名は area/category/sub_category が空のまま登録される。
fn make_product_rows_from_names(
    excel_path: &Path,
    names: &[String],
    lang_display: &str,
) -> Result<Vec<ProductListRow>, AppError> {
    if names.is_empty() {
        return Ok(Vec::new());
    }
    // 製品リストシートから全行を読む
    let all_rows = read_product_list(excel_path)?;

    // 言語でフィルタして 製品名→行 のマップを作成
    let is_en = lang_display.contains("英語") || lang_display.to_lowercase().contains("english");
    let row_map: std::collections::HashMap<String, &ProductListRow> = all_rows.iter()
        .filter(|r| {
            let en = r.lang.contains("英語") || r.lang.to_lowercase().contains("english");
            en == is_en
        })
        .map(|r| (r.product_name.clone(), r))
        .collect();

    let mut result = Vec::new();
    for name in names {
        if let Some(row) = row_map.get(name) {
            result.push((*row).clone());
        } else {
            // 製品リストにない → area/category/sub_category は空で登録
            result.push(ProductListRow {
                lang: lang_display.to_string(),
                area: String::new(),
                category: String::new(),
                sub_category: String::new(),
                product_name: name.clone(),
                dev_name: String::new(),
            });
        }
    }
    Ok(result)
}

/// prodinfolist.json から製品名→prod_id を引いて Vec<(prod_id, name)> を返す。
/// update_prodinfolist 後に呼ぶことで、自動追加済みの prod_id を取得する。
fn resolve_prod_ids(
    output_dir: &Path,
    lang: &str,
    names: &[String],
) -> Result<Vec<(String, String)>, AppError> {
    if names.is_empty() {
        return Ok(Vec::new());
    }
    let list_path = output_dir.join(lang).join("prodinfolist.json");
    if !list_path.exists() {
        return Ok(Vec::new());
    }
    let text = std::fs::read_to_string(&list_path).map_err(AppError::Io)?;
    let areas: Vec<crate::model::ProdInfoArea> = serde_json::from_str(&text)
        .map_err(|e| AppError::Store(StoreError::Deserialize {
            path: list_path.display().to_string(),
            source: e,
        }))?;

    // 製品名→prod_id マップ
    let mut name_to_id: std::collections::HashMap<String, String> = std::collections::HashMap::new();
    for area in &areas {
        for cat in &area.categories {
            for sub in &cat.sub_categories {
                for prod in &sub.products {
                    name_to_id.insert(prod.name.clone(), prod.id.clone());
                }
            }
        }
    }

    Ok(names.iter()
        .map(|n| (name_to_id.get(n).cloned().unwrap_or_default(), n.clone()))
        .collect())
}

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
