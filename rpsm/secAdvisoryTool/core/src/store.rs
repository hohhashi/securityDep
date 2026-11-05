//! v2 JSON ファイルを出力・削除するモジュール。
//!
//! 出力先:
//!   `<output_dir>/ja/vulinfo/{YYYY}/{id}.json`
//!   `<output_dir>/en/vulinfo/{YYYY}/{id}.json`
//!   `<output_dir>/ja/vulinfolist.json`  (更新)
//!   `<output_dir>/en/vulinfolist.json`  (更新)
//!
//! Excel の「公開日時」から年 (YYYY) を取得してサブディレクトリを決定する。

use std::fs;
use std::path::{Path, PathBuf};

use rust_xlsxwriter::{Format, Workbook};

use crate::model::{
    CveItem, JvnItem, ProdAdvisoryEntry, ProdInfoArea, ProdInfoCategory,
    ProdInfoFile, ProdInfoProduct, ProdInfoSubCategory, ProductListRow,
    VulinfoEntry, VulinfoRef, VulnDoc,
};

#[derive(Debug, thiserror::Error)]
pub enum StoreError {
    #[error("出力ディレクトリの作成に失敗しました: {0}")]
    CreateDir(std::io::Error),
    #[error("JSONファイルの書き込みに失敗しました: {path}: {source}")]
    Write { path: String, source: std::io::Error },
    #[error("JSONファイルの読み込みに失敗しました: {path}: {source}")]
    Read { path: String, source: std::io::Error },
    #[error("JSONファイルの削除に失敗しました: {path}: {source}")]
    Remove { path: String, source: std::io::Error },
    #[error("JSONのシリアライズに失敗しました: {0}")]
    Serialize(serde_json::Error),
    #[error("JSONのデシリアライズに失敗しました: {path}: {source}")]
    Deserialize { path: String, source: serde_json::Error },
}

/// ID から年を取り出すヘルパー（`ricoh-YYYY-NNNNNN` → `"YYYY"`）。
fn year_from_id(id: &str) -> &str {
    // "ricoh-2026-000001" → splits: ["ricoh", "2026", "000001"]
    let mut parts = id.splitn(3, '-');
    parts.next(); // "ricoh"
    parts.next().unwrap_or("0000")
}

/// `VulnDoc` を `{output_dir}/{lang}/vulinfo/{YYYY}/{id}.json` に書き出す。
///
/// `lang` は `"ja"` または `"en"` を渡す。
/// 年は `doc.published_at` の先頭4文字から取得する。
/// ディレクトリが存在しない場合は再帰的に作成する。
pub fn write_doc(output_dir: &Path, lang: &str, doc: &VulnDoc) -> Result<PathBuf, StoreError> {
    let year = if doc.published_at.len() >= 4 {
        &doc.published_at[..4]
    } else {
        "0000"
    };

    let dir = output_dir.join(lang).join("vulinfo").join(year);
    fs::create_dir_all(&dir).map_err(StoreError::CreateDir)?;

    let json_path = dir.join(format!("{}.json", doc.id));
    let text = serde_json::to_string_pretty(doc).map_err(StoreError::Serialize)?;

    fs::write(&json_path, text.as_bytes()).map_err(|e| StoreError::Write {
        path: json_path.display().to_string(),
        source: e,
    })?;

    Ok(json_path)
}

/// `{output_dir}/{lang}/vulinfolist.json` を更新する。
///
/// - ファイルが存在する場合:
///   - 同じ `id` のエントリがあれば先頭に移して上書き
///   - なければ先頭に追加
/// - ファイルが存在しない場合: 1件のみの配列として新規作成
pub fn update_vulinfolist(
    output_dir: &Path,
    lang: &str,
    doc: &VulnDoc,
) -> Result<PathBuf, StoreError> {
    let lang_dir = output_dir.join(lang);
    fs::create_dir_all(&lang_dir).map_err(StoreError::CreateDir)?;

    let list_path = lang_dir.join("vulinfolist.json");

    // 既存ファイルを読み込む（なければ空配列）
    let mut entries: Vec<VulinfoEntry> = if list_path.exists() {
        let text = fs::read_to_string(&list_path).map_err(|e| StoreError::Read {
            path: list_path.display().to_string(),
            source: e,
        })?;
        serde_json::from_str(&text).map_err(|e| StoreError::Deserialize {
            path: list_path.display().to_string(),
            source: e,
        })?
    } else {
        Vec::new()
    };

    // 今回のアドバイザリに対応するエントリを構築
    let new_entry = vulinfoentry_from_doc(doc);

    // 同じ ID のエントリを削除してから先頭に挿入
    entries.retain(|e| e.id != doc.id);
    entries.insert(0, new_entry);

    // 書き出し
    let text = serde_json::to_string_pretty(&entries).map_err(StoreError::Serialize)?;
    fs::write(&list_path, text.as_bytes()).map_err(|e| StoreError::Write {
        path: list_path.display().to_string(),
        source: e,
    })?;

    Ok(list_path)
}

// ---------- 内部ヘルパー ----------

fn vulinfoentry_from_doc(doc: &VulnDoc) -> VulinfoEntry {
    VulinfoEntry {
        id: doc.id.clone(),
        title: doc.title.clone(),
        importance: String::new(), // 入力シートに対応フィールドなし
        severity: doc.severity.clone(),
        cve: doc.cve_list.iter().map(cve_to_ref).collect(),
        jvn: doc.jvn.iter().map(jvn_to_ref).collect(),
        published_at: doc.published_at.clone(),
        updated_at: doc.updated_at.clone(),
    }
}

fn cve_to_ref(c: &CveItem) -> VulinfoRef {
    VulinfoRef {
        id: c.id.clone(),
        url: c.url.clone(),
    }
}

fn jvn_to_ref(j: &JvnItem) -> VulinfoRef {
    VulinfoRef {
        id: j.id.clone(),
        url: j.url.clone(),
    }
}

// ---- prodinfolist.json 操作 ----

/// `{output_dir}/ja/prodinfolist.json` から全 prod_id を収集して返す。
///
/// ファイルが存在しない場合は空の HashSet を返す。
pub fn read_prodinfolist_prod_ids(
    output_dir: &Path,
    lang: &str,
) -> Result<std::collections::HashSet<String>, StoreError> {
    let list_path = output_dir.join(lang).join("prodinfolist.json");
    if !list_path.exists() {
        return Ok(std::collections::HashSet::new());
    }

    let text = fs::read_to_string(&list_path).map_err(|e| StoreError::Read {
        path: list_path.display().to_string(),
        source: e,
    })?;

    let areas: Vec<ProdInfoArea> = serde_json::from_str(&text).map_err(|e| StoreError::Deserialize {
        path: list_path.display().to_string(),
        source: e,
    })?;

    let mut ids = std::collections::HashSet::new();
    for area in &areas {
        for cat in &area.categories {
            for sub in &cat.sub_categories {
                for prod in &sub.products {
                    ids.insert(prod.id.clone());
                }
            }
        }
    }
    Ok(ids)
}

/// `{output_dir}/{lang}/prodinfolist.json` に ProductListRow のスライスをマージする。
///
/// - 既存エントリは事業→カテゴリ→サブカテゴリの階層に prod_id をキーとして upsert する。
/// - 削除はしない。
/// - ファイルが存在しない場合は新規作成する。
pub fn update_prodinfolist(
    output_dir: &Path,
    lang: &str,
    rows: &[ProductListRow],
) -> Result<PathBuf, StoreError> {
    let lang_dir = output_dir.join(lang);
    fs::create_dir_all(&lang_dir).map_err(StoreError::CreateDir)?;
    let list_path = lang_dir.join("prodinfolist.json");

    // 既存ファイルを読み込む
    let mut areas: Vec<ProdInfoArea> = if list_path.exists() {
        let text = fs::read_to_string(&list_path).map_err(|e| StoreError::Read {
            path: list_path.display().to_string(),
            source: e,
        })?;
        serde_json::from_str(&text).map_err(|e| StoreError::Deserialize {
            path: list_path.display().to_string(),
            source: e,
        })?
    } else {
        Vec::new()
    };

    for row in rows {
        // 事業を探す or 追加
        let area = match areas.iter_mut().find(|a| a.name == row.area) {
            Some(a) => a,
            None => {
                areas.push(ProdInfoArea { name: row.area.clone(), categories: Vec::new() });
                areas.last_mut().unwrap()
            }
        };

        // カテゴリを探す or 追加
        let cat = match area.categories.iter_mut().find(|c| c.name == row.category) {
            Some(c) => c,
            None => {
                area.categories.push(ProdInfoCategory {
                    name: row.category.clone(),
                    sub_categories: Vec::new(),
                });
                area.categories.last_mut().unwrap()
            }
        };

        // サブカテゴリを探す or 追加
        let sub = match cat.sub_categories.iter_mut().find(|s| s.name == row.sub_category) {
            Some(s) => s,
            None => {
                cat.sub_categories.push(ProdInfoSubCategory {
                    name: row.sub_category.clone(),
                    products: Vec::new(),
                });
                cat.sub_categories.last_mut().unwrap()
            }
        };

        // prod_id で upsert
        match sub.products.iter_mut().find(|p| p.id == row.prod_id) {
            Some(p) => p.name = row.product_name.clone(), // 名前更新
            None => sub.products.push(ProdInfoProduct {
                name: row.product_name.clone(),
                id: row.prod_id.clone(),
            }),
        }
    }

    let text = serde_json::to_string_pretty(&areas).map_err(StoreError::Serialize)?;
    fs::write(&list_path, text.as_bytes()).map_err(|e| StoreError::Write {
        path: list_path.display().to_string(),
        source: e,
    })?;

    Ok(list_path)
}

// ---- prodXXX.json 操作 ----

/// `{output_dir}/{lang}/prodinfo/{prod_id}.json` を作成 or 更新する。
///
/// - ファイルが存在しない場合: 新規作成（advisories に entry を 1 件追加）
/// - 存在する場合: 同じ `entry.id` があれば上書き、なければ先頭に追加
/// - `prod_name` はファイル新規作成時の `name` フィールドに使う
///   （既存ファイルは name を保持する）
pub fn update_prodinfo_file(
    output_dir: &Path,
    lang: &str,
    prod_id: &str,
    prod_name: &str,
    entry: ProdAdvisoryEntry,
) -> Result<PathBuf, StoreError> {
    let dir = output_dir.join(lang).join("prodinfo");
    fs::create_dir_all(&dir).map_err(StoreError::CreateDir)?;
    let file_path = dir.join(format!("{}.json", prod_id));

    let mut prod_file: ProdInfoFile = if file_path.exists() {
        let text = fs::read_to_string(&file_path).map_err(|e| StoreError::Read {
            path: file_path.display().to_string(),
            source: e,
        })?;
        serde_json::from_str(&text).map_err(|e| StoreError::Deserialize {
            path: file_path.display().to_string(),
            source: e,
        })?
    } else {
        ProdInfoFile {
            version: "2.0".to_string(),
            name: prod_name.to_string(),
            id: prod_id.to_string(),
            advisories: Vec::new(),
        }
    };

    // 旧フォーマット（version なし）をマイグレーション
    if prod_file.version.is_empty() {
        prod_file.version = "2.0".to_string();
    }

    // 同一 ID があれば先に除去してから先頭に挿入
    prod_file.advisories.retain(|a| a.id != entry.id);
    prod_file.advisories.insert(0, entry);

    let text = serde_json::to_string_pretty(&prod_file).map_err(StoreError::Serialize)?;
    fs::write(&file_path, text.as_bytes()).map_err(|e| StoreError::Write {
        path: file_path.display().to_string(),
        source: e,
    })?;

    Ok(file_path)
}

// ---- 削除系 ----

/// `{output_dir}/{lang}/vulinfo/{YYYY}/{id}.json` を削除する。
///
/// ファイルが存在しない場合は何もせず `None` を返す。
/// 削除できた場合は削除したパスを `Some` で返す。
pub fn delete_doc(output_dir: &Path, lang: &str, id: &str) -> Result<Option<PathBuf>, StoreError> {
    let year = year_from_id(id);
    let json_path = output_dir
        .join(lang)
        .join("vulinfo")
        .join(year)
        .join(format!("{}.json", id));

    if !json_path.exists() {
        return Ok(None);
    }

    fs::remove_file(&json_path).map_err(|e| StoreError::Remove {
        path: json_path.display().to_string(),
        source: e,
    })?;

    Ok(Some(json_path))
}

/// `{output_dir}/{lang}/vulinfolist.json` から指定 ID のエントリを削除する。
///
/// ファイルが存在しない、または対象 ID が含まれない場合は何もせず `None` を返す。
/// 削除できた場合は `vulinfolist.json` のパスを `Some` で返す。
pub fn remove_from_vulinfolist(
    output_dir: &Path,
    lang: &str,
    id: &str,
) -> Result<Option<PathBuf>, StoreError> {
    let list_path = output_dir.join(lang).join("vulinfolist.json");

    if !list_path.exists() {
        return Ok(None);
    }

    let text = fs::read_to_string(&list_path).map_err(|e| StoreError::Read {
        path: list_path.display().to_string(),
        source: e,
    })?;

    let mut entries: Vec<VulinfoEntry> =
        serde_json::from_str(&text).map_err(|e| StoreError::Deserialize {
            path: list_path.display().to_string(),
            source: e,
        })?;

    let before_len = entries.len();
    entries.retain(|e| e.id != id);

    if entries.len() == before_len {
        // 対象 ID が存在しなかった
        return Ok(None);
    }

    let text = serde_json::to_string_pretty(&entries).map_err(StoreError::Serialize)?;
    fs::write(&list_path, text.as_bytes()).map_err(|e| StoreError::Write {
        path: list_path.display().to_string(),
        source: e,
    })?;

    Ok(Some(list_path))
}

/// `{output_dir}/{lang}/prodinfo/` 以下の全 JSON ファイルから
/// 指定アドバイザリ ID のエントリを除去する。
///
/// 変更したファイルのパス一覧を返す（該当 ID を含まないファイルはスキップ）。
pub fn remove_advisory_from_prodinfo(
    output_dir: &Path,
    lang: &str,
    advisory_id: &str,
) -> Result<Vec<PathBuf>, StoreError> {
    let prodinfo_dir = output_dir.join(lang).join("prodinfo");
    if !prodinfo_dir.exists() {
        return Ok(Vec::new());
    }

    let mut updated = Vec::new();

    let entries = fs::read_dir(&prodinfo_dir).map_err(|e| StoreError::Read {
        path: prodinfo_dir.display().to_string(),
        source: e,
    })?;

    for entry in entries {
        let entry = entry.map_err(|e| StoreError::Read {
            path: prodinfo_dir.display().to_string(),
            source: e,
        })?;
        let path = entry.path();
        if path.extension().and_then(|e| e.to_str()) != Some("json") {
            continue;
        }

        let text = fs::read_to_string(&path).map_err(|e| StoreError::Read {
            path: path.display().to_string(),
            source: e,
        })?;

        let mut prod_file: ProdInfoFile =
            serde_json::from_str(&text).map_err(|e| StoreError::Deserialize {
                path: path.display().to_string(),
                source: e,
            })?;

        let before_len = prod_file.advisories.len();
        prod_file.advisories.retain(|a| a.id != advisory_id);

        if prod_file.advisories.len() == before_len {
            continue; // 変更なし
        }

        let new_text = serde_json::to_string_pretty(&prod_file).map_err(StoreError::Serialize)?;
        fs::write(&path, new_text.as_bytes()).map_err(|e| StoreError::Write {
            path: path.display().to_string(),
            source: e,
        })?;

        updated.push(path);
    }

    Ok(updated)
}

// ---- prodinfolist.json → Excel エクスポート ----

/// `{output_dir}/ja/prodinfolist.json` と `{output_dir}/en/prodinfolist.json` を読み込み、
/// 採番済機種リスト(日) / 採番済機種リスト(英) の2シート構成の Excel ファイルを出力する。
///
/// 列構成: A=prod_id  B=事業  C=カテゴリ  D=サブカテゴリ  E=製品・サービス名
///
/// `out_path` が None の場合は `{output_dir}/採番済機種リスト_export.xlsx` に出力する。
pub fn export_prodinfolist(
    output_dir: &Path,
    out_path: Option<&Path>,
) -> Result<PathBuf, StoreError> {
    let mut workbook = Workbook::new();

    // 基本書式（Meiryo UI）
    let base_fmt = Format::new().set_font_name("Meiryo UI");
    // ヘッダー書式（Meiryo UI + 太字）
    let header_fmt = Format::new().set_font_name("Meiryo UI").set_bold();

    for (lang, sheet_name, headers) in &[
        ("ja", "採番済機種リスト(日)", ["prod_id", "事業", "カテゴリ", "サブカテゴリ", "製品・サービス名"]),
        ("en", "採番済機種リスト(英)", ["prod_id", "Area", "Category", "Sub Category", "Product/Service Name"]),
    ] {
        let list_path = output_dir.join(lang).join("prodinfolist.json");

        let areas: Vec<ProdInfoArea> = if list_path.exists() {
            let text = fs::read_to_string(&list_path).map_err(|e| StoreError::Read {
                path: list_path.display().to_string(),
                source: e,
            })?;
            serde_json::from_str(&text).map_err(|e| StoreError::Deserialize {
                path: list_path.display().to_string(),
                source: e,
            })?
        } else {
            Vec::new()
        };

        // シートを追加
        let ws = workbook.add_worksheet();
        ws.set_name(*sheet_name).map_err(|e| StoreError::Write {
            path: format!("sheet:{}", sheet_name),
            source: std::io::Error::other(e.to_string()),
        })?;

        // ヘッダー行
        for (col, h) in headers.iter().enumerate() {
            ws.write_with_format(0, col as u16, *h, &header_fmt)
                .map_err(|e| StoreError::Write {
                    path: format!("sheet:{}", sheet_name),
                    source: std::io::Error::other(e.to_string()),
                })?;
        }

        // データ行
        let mut row: u32 = 1;
        for area in &areas {
            for cat in &area.categories {
                for sub in &cat.sub_categories {
                    for prod in &sub.products {
                        // A: prod_id
                        ws.write_with_format(row, 0, prod.id.as_str(), &base_fmt).ok();
                        // B: 事業
                        ws.write_with_format(row, 1, area.name.as_str(), &base_fmt).ok();
                        // C: カテゴリ
                        ws.write_with_format(row, 2, cat.name.as_str(), &base_fmt).ok();
                        // D: サブカテゴリ
                        ws.write_with_format(row, 3, sub.name.as_str(), &base_fmt).ok();
                        // E: 製品・サービス名
                        ws.write_with_format(row, 4, prod.name.as_str(), &base_fmt).ok();
                        row += 1;
                    }
                }
            }
        }

        // 列幅を自動調整（簡易）
        ws.autofit();
    }

    let xlsx_path = out_path
        .map(|p| p.to_path_buf())
        .unwrap_or_else(|| std::env::current_dir()
            .unwrap_or_else(|_| std::path::PathBuf::from("."))
            .join("採番済機種リスト_export.xlsx"));

    // 出力先ディレクトリが存在しない場合は作成する
    if let Some(parent) = xlsx_path.parent() {
        if !parent.as_os_str().is_empty() {
            fs::create_dir_all(parent).map_err(StoreError::CreateDir)?;
        }
    }

    workbook.save(&xlsx_path).map_err(|e| StoreError::Write {
        path: xlsx_path.display().to_string(),
        source: std::io::Error::other(e.to_string()),
    })?;

    Ok(xlsx_path)
}
