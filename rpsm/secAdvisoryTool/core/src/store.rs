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

use rust_xlsxwriter::{DataValidation, Format, Formula, Workbook};

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
/// - 内容に変化がない場合はファイルを書き込まず `None` を返す
pub fn update_vulinfolist(
    output_dir: &Path,
    lang: &str,
    doc: &VulnDoc,
) -> Result<Option<PathBuf>, StoreError> {
    let lang_dir = output_dir.join(lang);
    fs::create_dir_all(&lang_dir).map_err(StoreError::CreateDir)?;

    let list_path = lang_dir.join("vulinfolist.json");

    // 既存ファイルを読み込む（なければ空配列）
    let (existing_text, mut entries): (Option<String>, Vec<VulinfoEntry>) = if list_path.exists() {
        let text = fs::read_to_string(&list_path).map_err(|e| StoreError::Read {
            path: list_path.display().to_string(),
            source: e,
        })?;
        let entries = serde_json::from_str(&text).map_err(|e| StoreError::Deserialize {
            path: list_path.display().to_string(),
            source: e,
        })?;
        (Some(text), entries)
    } else {
        (None, Vec::new())
    };

    // 今回のアドバイザリに対応するエントリを構築
    let new_entry = vulinfoentry_from_doc(doc);

    // 同じ ID のエントリを削除してから先頭に挿入
    entries.retain(|e| e.id != doc.id);
    entries.insert(0, new_entry);

    // 新しい JSON を生成
    let new_text = serde_json::to_string_pretty(&entries).map_err(StoreError::Serialize)?;

    // 内容に変化がなければスキップ
    if existing_text.as_deref() == Some(new_text.as_str()) {
        return Ok(None);
    }

    // 書き出し
    fs::write(&list_path, new_text.as_bytes()).map_err(|e| StoreError::Write {
        path: list_path.display().to_string(),
        source: e,
    })?;

    Ok(Some(list_path))
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

/// 複合キー（事業 + カテゴリ + サブカテゴリ + 製品名）で prodinfolist を upsert する。
///
/// - prod_id は JSON 側のみで管理。入力行が既存エントリと複合キーで一致した場合は
///   prod_id を引き継ぐ。新規の場合は自動採番する。
/// - 削除はしない（create / update 用）。
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

    // 採番用の最大番号を事前に計算（ボローチェック回避のため areas からは独立して管理）
    let mut max_num = collect_max_prod_num(&areas, output_dir, lang);

    for row in rows {
        let area_idx = match areas.iter().position(|a| a.name == row.area) {
            Some(i) => i,
            None => {
                areas.push(ProdInfoArea { name: row.area.clone(), categories: Vec::new() });
                areas.len() - 1
            }
        };
        let cat_idx = match areas[area_idx].categories.iter().position(|c| c.name == row.category) {
            Some(i) => i,
            None => {
                areas[area_idx].categories.push(ProdInfoCategory {
                    name: row.category.clone(),
                    sub_categories: Vec::new(),
                });
                areas[area_idx].categories.len() - 1
            }
        };
        let sub_idx = match areas[area_idx].categories[cat_idx].sub_categories.iter().position(|s| s.name == row.sub_category) {
            Some(i) => i,
            None => {
                areas[area_idx].categories[cat_idx].sub_categories.push(ProdInfoSubCategory {
                    name: row.sub_category.clone(),
                    products: Vec::new(),
                });
                areas[area_idx].categories[cat_idx].sub_categories.len() - 1
            }
        };

        let products = &mut areas[area_idx].categories[cat_idx].sub_categories[sub_idx].products;

        // 複合キー（製品名）で既存エントリを探す
        if products.iter().any(|p| p.name == row.product_name) {
            // 既存エントリあり → prod_id はそのまま保持
        } else {
            // 新規エントリ: 自動採番
            max_num += 1;
            let prod_id = format!("prod{:06}_v2", max_num);
            products.push(ProdInfoProduct {
                name: row.product_name.clone(),
                id: prod_id,
            });
        }
    }

    let text = serde_json::to_string_pretty(&areas).map_err(StoreError::Serialize)?;
    fs::write(&list_path, text.as_bytes()).map_err(|e| StoreError::Write {
        path: list_path.display().to_string(),
        source: e,
    })?;

    Ok(list_path)
}

/// sync-products 専用: prodinfolist.json を入力行で**完全置換**する。
///
/// - 既存の prodinfolist.json を読み込み、既存 prod_id を引き継ぐ。
/// - 入力行にない既存エントリは削除される（prodinfo/{id}.json ファイルは残る）。
/// - 新規エントリは prod_id を自動採番または入力行の値を使う。
pub fn replace_prodinfolist(
    output_dir: &Path,
    lang: &str,
    rows: &[ProductListRow],
) -> Result<PathBuf, StoreError> {
    let lang_dir = output_dir.join(lang);
    fs::create_dir_all(&lang_dir).map_err(StoreError::CreateDir)?;
    let list_path = lang_dir.join("prodinfolist.json");

    // 既存の (製品名 → prod_id) マップを構築
    let existing_id_map: std::collections::HashMap<String, String> = if list_path.exists() {
        let text = fs::read_to_string(&list_path).map_err(|e| StoreError::Read {
            path: list_path.display().to_string(),
            source: e,
        })?;
        let old_areas: Vec<ProdInfoArea> = serde_json::from_str(&text).map_err(|e| StoreError::Deserialize {
            path: list_path.display().to_string(),
            source: e,
        })?;
        let mut map = std::collections::HashMap::new();
        for area in &old_areas {
            for cat in &area.categories {
                for sub in &cat.sub_categories {
                    for prod in &sub.products {
                        map.insert(prod.name.clone(), prod.id.clone());
                    }
                }
            }
        }
        map
    } else {
        std::collections::HashMap::new()
    };

    // 既存の最大 prod 番号を把握（採番に使う）
    let max_num: u32 = existing_id_map.values()
        .filter_map(|id| parse_prod_num(id))
        .max()
        .unwrap_or(0);
    let mut next_num = max_num + 1;

    // 入力行から新しい prodinfolist を組み立てる
    let mut areas: Vec<ProdInfoArea> = Vec::new();

    for row in rows {
        let area = match areas.iter_mut().find(|a| a.name == row.area) {
            Some(a) => a,
            None => {
                areas.push(ProdInfoArea { name: row.area.clone(), categories: Vec::new() });
                areas.last_mut().unwrap()
            }
        };
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

        // 重複製品名はスキップ
        if sub.products.iter().any(|p| p.name == row.product_name) {
            continue;
        }

        // prod_id を決定
        // 優先順位: 1. 既存マップから引く（複合キー一致）  2. 採番
        let prod_id = if let Some(id) = existing_id_map.get(&row.product_name) {
            id.clone()
        } else {
            let id = format!("prod{:06}_v2", next_num);
            next_num += 1;
            id
        };

        sub.products.push(ProdInfoProduct {
            name: row.product_name.clone(),
            id: prod_id,
        });
    }

    let text = serde_json::to_string_pretty(&areas).map_err(StoreError::Serialize)?;
    fs::write(&list_path, text.as_bytes()).map_err(|e| StoreError::Write {
        path: list_path.display().to_string(),
        source: e,
    })?;

    Ok(list_path)
}

/// prod_id 文字列から番号部分を取り出す。
///
/// フォーマット: `prod{NNNNNN}_v2` または旧フォーマット `prod{NNNNNN}`
/// 例: `prod000001_v2` → 1, `prod000287` → 287
fn parse_prod_num(id: &str) -> Option<u32> {
    let body = id.strip_prefix("prod")?;
    // "_v2" サフィックスを除去してから数値パース
    let num_str = body.trim_end_matches("_v2");
    num_str.parse::<u32>().ok()
}

/// 現在の areas と他言語の prodinfolist.json を参照して最大の prod 番号を返す。
/// 採番時は +1 してから使う。ボロー問題を避けるため &self ではなく slice を受け取る。
fn collect_max_prod_num(areas: &[ProdInfoArea], output_dir: &Path, lang: &str) -> u32 {
    let list_path = output_dir.join(lang).join("prodinfolist.json");
    let mut max_num = 0u32;

    // 渡された areas から最大番号を収集
    for area in areas {
        for cat in &area.categories {
            for sub in &cat.sub_categories {
                for prod in &sub.products {
                    if let Some(n) = parse_prod_num(&prod.id) {
                        if n > max_num { max_num = n; }
                    }
                }
            }
        }
    }

    // 他言語のファイルからも収集（ja/en 間で prod_id が重複しないようにする）
    for l in &["ja", "en"] {
        let p = output_dir.join(l).join("prodinfolist.json");
        if p == list_path { continue; }
        if let Ok(text) = fs::read_to_string(&p) {
            if let Ok(old_areas) = serde_json::from_str::<Vec<ProdInfoArea>>(&text) {
                for area in &old_areas {
                    for cat in &area.categories {
                        for sub in &cat.sub_categories {
                            for prod in &sub.products {
                                if let Some(n) = parse_prod_num(&prod.id) {
                                    if n > max_num { max_num = n; }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    max_num
}

// ---- prodXXX.json 操作 ----

/// `{output_dir}/{lang}/prodinfo/{prod_id}.json` を作成 or 更新する。
///
/// - ファイルが存在しない場合: 新規作成（advisories に entry を 1 件追加）
/// - 存在する場合: 同じ `entry.id` があれば上書き、なければ先頭に追加
/// - `prod_name` はファイル新規作成時の `name` フィールドに使う
///   （既存ファイルは name を保持する）
/// - 内容に変化がない場合はファイルを書き込まず `None` を返す
pub fn update_prodinfo_file(
    output_dir: &Path,
    lang: &str,
    prod_id: &str,
    prod_name: &str,
    entry: ProdAdvisoryEntry,
) -> Result<Option<PathBuf>, StoreError> {
    let dir = output_dir.join(lang).join("prodinfo");
    fs::create_dir_all(&dir).map_err(StoreError::CreateDir)?;
    let file_path = dir.join(format!("{}.json", prod_id));

    let (existing_text, mut prod_file): (Option<String>, ProdInfoFile) = if file_path.exists() {
        let text = fs::read_to_string(&file_path).map_err(|e| StoreError::Read {
            path: file_path.display().to_string(),
            source: e,
        })?;
        let pf = serde_json::from_str(&text).map_err(|e| StoreError::Deserialize {
            path: file_path.display().to_string(),
            source: e,
        })?;
        (Some(text), pf)
    } else {
        (None, ProdInfoFile {
            version: "2.0".to_string(),
            name: prod_name.to_string(),
            id: prod_id.to_string(),
            advisories: Vec::new(),
        })
    };

    // 旧フォーマット（version なし）をマイグレーション
    if prod_file.version.is_empty() {
        prod_file.version = "2.0".to_string();
    }

    // 同一 ID があれば先に除去してから先頭に挿入
    prod_file.advisories.retain(|a| a.id != entry.id);
    prod_file.advisories.insert(0, entry);

    // 新しい JSON を生成
    let new_text = serde_json::to_string_pretty(&prod_file).map_err(StoreError::Serialize)?;

    // 内容に変化がなければスキップ
    if existing_text.as_deref() == Some(new_text.as_str()) {
        return Ok(None);
    }

    fs::write(&file_path, new_text.as_bytes()).map_err(|e| StoreError::Write {
        path: file_path.display().to_string(),
        source: e,
    })?;

    Ok(Some(file_path))
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

/// 列インデックス (0始まり) を Excel の列文字に変換する（例: 0→"A", 25→"Z", 26→"AA"）。
fn col_letter(col: u16) -> String {
    let mut result = String::new();
    let mut n = col as u32 + 1; // 1始まりに変換
    while n > 0 {
        n -= 1;
        result.insert(0, (b'A' + (n % 26) as u8) as char);
        n /= 26;
    }
    result
}

/// 列インデックス定数（製品リストシートの列構成）
/// A=0: 言語
/// B=1: 事業
/// C=2: カテゴリ
/// D=3: サブカテゴリ
/// E=4: 製品・サービス名
/// F=5: 補足（開発名など）（非表示）
/// prod_id 列は存在しない。prod_id は prodinfolist.json 側のみで管理する。
const COL_LANG: u16 = 0;
const COL_AREA: u16 = 1;
const COL_CATEGORY: u16 = 2;
const COL_SUB_CATEGORY: u16 = 3;
const COL_PRODUCT_NAME: u16 = 4;
const COL_DEV_NAME: u16 = 5;

/// `{output_dir}/ja/prodinfolist.json` と `{output_dir}/en/prodinfolist.json` を読み込み、
/// 製品リスト(日) / 製品リスト(英) の2シート構成の Excel ファイルを出力する。
///
/// 列構成:
///   A=prod_id（非表示）  B=言語  C=事業  D=カテゴリ  E=サブカテゴリ
///   F=製品・サービス名  G=補足（開発名など）（非表示、背景色変更）
///
/// カテゴリ・サブカテゴリのドロップダウンは `cfg` のマスタから生成する。
/// `out_path` が None の場合は `{output_dir}/製品リスト_export.xlsx` に出力する。
pub fn export_prodinfolist(
    output_dir: &Path,
    out_path: Option<&Path>,
    cfg: &crate::config::Config,
) -> Result<PathBuf, StoreError> {
    let mut workbook = Workbook::new();

    // 書式
    let base_fmt = Format::new().set_font_name("Meiryo UI");
    let header_fmt = Format::new()
        .set_font_name("Meiryo UI")
        .set_bold()
        .set_background_color(rust_xlsxwriter::Color::RGB(0x4472C4))
        .set_font_color(rust_xlsxwriter::Color::White);
    // 補足列ヘッダー（背景色を変えて区別）
    let dev_header_fmt = Format::new()
        .set_font_name("Meiryo UI")
        .set_bold()
        .set_background_color(rust_xlsxwriter::Color::RGB(0x9DC3E6))
        .set_font_color(rust_xlsxwriter::Color::RGB(0x1F3864));

    let sheet_configs: &[(&str, &str, &str, &str, &str, &str, &str)] = &[
        // (lang, sheet_name, h_lang, h_area, h_category, h_sub_category, h_product_name)
        ("ja", "製品リスト(日)", "言語", "事業", "カテゴリ", "サブカテゴリ", "製品・サービス名"),
        ("en", "製品リスト(英)", "Language", "Area", "Category", "Sub Category", "Product/Service Name"),
    ];

    for (lang, sheet_name, h_lang, h_area, h_cat, h_sub, h_prod) in sheet_configs {
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

        let ws = workbook.add_worksheet();
        ws.set_name(*sheet_name).map_err(|e| StoreError::Write {
            path: format!("sheet:{}", sheet_name),
            source: std::io::Error::other(e.to_string()),
        })?;

        // ---- ヘッダー行 ----
        ws.write_with_format(0, COL_LANG,          *h_lang,     &header_fmt).ok();
        ws.write_with_format(0, COL_AREA,          *h_area,     &header_fmt).ok();
        ws.write_with_format(0, COL_CATEGORY,      *h_cat,      &header_fmt).ok();
        ws.write_with_format(0, COL_SUB_CATEGORY,  *h_sub,      &header_fmt).ok();
        ws.write_with_format(0, COL_PRODUCT_NAME,  *h_prod,     &header_fmt).ok();
        // 補足列ヘッダー（背景色を変えて区別・非表示）
        let dev_label = if *lang == "ja" { "補足（開発名など）" } else { "Notes (dev name, etc.)" };
        ws.write_with_format(0, COL_DEV_NAME, dev_label, &dev_header_fmt).ok();

        // ---- データ行 ----
        // 言語表示文字列
        let lang_display = if *lang == "ja" { "日本語" } else { "英語" };
        let mut row: u32 = 1;
        for area in &areas {
            for cat in &area.categories {
                for sub in &cat.sub_categories {
                    for prod in &sub.products {
                        ws.write_with_format(row, COL_LANG,         lang_display,        &base_fmt).ok();
                        ws.write_with_format(row, COL_AREA,         area.name.as_str(),  &base_fmt).ok();
                        ws.write_with_format(row, COL_CATEGORY,     cat.name.as_str(),   &base_fmt).ok();
                        ws.write_with_format(row, COL_SUB_CATEGORY, sub.name.as_str(),   &base_fmt).ok();
                        ws.write_with_format(row, COL_PRODUCT_NAME, prod.name.as_str(),  &base_fmt).ok();
                        // dev_name は prodinfolist.json に含まれないため空欄（F列は非表示）
                        row += 1;
                    }
                }
            }
        }

        // ---- 連動ドロップダウン（マスタがある場合のみ） ----
        // 補助シート名 + Named Range + INDIRECT で3段連動を実現する。
        // 補助シートは後で追加するので、ここでは Named Range 参照式のみ設定する。
        let cat_areas = cfg.categories_for_lang(lang);
        if !cat_areas.is_empty() {
            let dv_last_row = row.max(1000) as u32;
            let lang_key = if *lang == "ja" { "ja" } else { "en" };
            let master_sheet = format!("_マスタ_{}", lang_key);

            // --- 事業ドロップダウン (C列): Named Range "AREA_ja" / "AREA_en" ---
            let area_range_name = format!("AREA_{}", lang_key);
            let dv_area = DataValidation::new()
                .allow_list_formula(Formula::new(format!("INDIRECT(\"{}\")", area_range_name)));
            ws.add_data_validation(1, COL_AREA, dv_last_row, COL_AREA, &dv_area)
                .map_err(|e| StoreError::Write {
                    path: format!("sheet:{} dropdown:area", sheet_name),
                    source: std::io::Error::other(e.to_string()),
                })?;

            // --- カテゴリドロップダウン (D列) ---
            // C列の事業値に対応する Named Range "CAT_{lang}_{area_idx}" を INDIRECT で参照。
            // MATCH(C2, AREA_ja, 0) - 1 で area_idx (0始まり) を求め、文字列連結。
            // ただし INDIRECT の引数には式は書けない（文字列のみ）ため、
            // INDIRECT(CONCAT(...)) 相当の INDIRECT("CAT_ja_"&TEXT(MATCH(...)-1,"0")) を使う。
            let cat_dv_formula = format!(
                "INDIRECT(\"CAT_{lang}_\"&TEXT(MATCH({area_col}2,INDIRECT(\"AREA_{lang}\"),0)-1,\"0\"))",
                lang = lang_key,
                area_col = col_letter(COL_AREA),
            );
            let dv_cat = DataValidation::new()
                .allow_list_formula(Formula::new(cat_dv_formula));
            ws.add_data_validation(1, COL_CATEGORY, dv_last_row, COL_CATEGORY, &dv_cat)
                .map_err(|e| StoreError::Write {
                    path: format!("sheet:{} dropdown:category", sheet_name),
                    source: std::io::Error::other(e.to_string()),
                })?;

            // --- サブカテゴリドロップダウン (E列) ---
            // 事業インデックス (ai) とカテゴリインデックス (ci) を組み合わせた
            // Named Range "SUB_{lang}_{ai}_{ci}" を参照する。
            let sub_dv_formula = format!(
                "INDIRECT(\"SUB_{lang}_\"&TEXT(MATCH({area_col}2,INDIRECT(\"AREA_{lang}\"),0)-1,\"0\")&\"_\"&TEXT(MATCH({cat_col}2,INDIRECT(\"CAT_{lang}_\"&TEXT(MATCH({area_col}2,INDIRECT(\"AREA_{lang}\"),0)-1,\"0\")),0)-1,\"0\"))",
                lang = lang_key,
                area_col = col_letter(COL_AREA),
                cat_col = col_letter(COL_CATEGORY),
            );
            let dv_sub = DataValidation::new()
                .allow_list_formula(Formula::new(sub_dv_formula));
            ws.add_data_validation(1, COL_SUB_CATEGORY, dv_last_row, COL_SUB_CATEGORY, &dv_sub)
                .map_err(|e| StoreError::Write {
                    path: format!("sheet:{} dropdown:sub", sheet_name),
                    source: std::io::Error::other(e.to_string()),
                })?;

            // Named Range と補助シートの情報を収集（後でまとめて追加）
            // ここでは master_sheet の名前だけ保存。実際の書き込みはループ後。
            let _ = master_sheet; // 後で使用
        }

        // ---- 列幅・非表示設定 ----
        ws.autofit();
        // F列(補足)を非表示
        ws.set_column_hidden(COL_DEV_NAME).map_err(|e| StoreError::Write {
            path: format!("sheet:{} hide:dev_name", sheet_name),
            source: std::io::Error::other(e.to_string()),
        })?;
        // 言語列(A)は幅固定
        ws.set_column_width(COL_LANG, 10.0).map_err(|e| StoreError::Write {
            path: format!("sheet:{} width:lang", sheet_name),
            source: std::io::Error::other(e.to_string()),
        })?;
    }

    // ---- 補助シートの書き出しと Named Range 定義 ----
    // 各言語の事業/カテゴリ/サブカテゴリマスタを非表示シートに書き出し、
    // Named Range を定義することで INDIRECT 連動ドロップダウンを実現する。
    //
    // ボロー制約回避のため:
    //   Phase 1: 補助シートにデータを書き出し、Named Range 情報を Vec に収集
    //   Phase 2: ms のドロップ後に workbook.define_name() をまとめて呼ぶ
    for lang in &["ja", "en"] {
        let cat_areas = cfg.categories_for_lang(lang);
        if cat_areas.is_empty() { continue; }

        let lang_key = if *lang == "ja" { "ja" } else { "en" };
        let master_sheet_name = format!("_マスタ_{}", lang_key);

        // Phase 1: データ書き出し＆Named Range 情報収集
        // (name, formula) のペアを Vec に溜める
        let mut named_ranges: Vec<(String, String)> = Vec::new();
        {
            let ms = workbook.add_worksheet();
            ms.set_name(&master_sheet_name).map_err(|e| StoreError::Write {
                path: format!("sheet:{}", master_sheet_name),
                source: std::io::Error::other(e.to_string()),
            })?;
            ms.set_hidden(true);

            // A列: 事業一覧 (AREA_{lang})
            let area_names: Vec<&str> = cat_areas.iter().map(|a| a.area.as_str()).collect();
            let area_count = area_names.len() as u32;
            for (r, name) in area_names.iter().enumerate() {
                ms.write(r as u32, 0, *name).ok();
            }
            named_ranges.push((
                format!("AREA_{}", lang_key),
                format!("='{}'!$A$1:$A${}", master_sheet_name, area_count),
            ));

            // B列以降: 各事業のカテゴリ (CAT_{lang}_{area_idx})
            let mut sub_col: u16 = 1 + cat_areas.len() as u16;

            for (area_idx, area_cfg) in cat_areas.iter().enumerate() {
                let cat_col = (1 + area_idx) as u16;
                let cat_names: Vec<&str> = area_cfg.categories.iter()
                    .map(|c| c.name.as_str())
                    .collect();
                let cat_count = cat_names.len() as u32;

                for (r, name) in cat_names.iter().enumerate() {
                    ms.write(r as u32, cat_col, *name).ok();
                }

                if cat_count > 0 {
                    let cl = col_letter(cat_col);
                    named_ranges.push((
                        format!("CAT_{}_{}", lang_key, area_idx),
                        format!("='{}'!${}$1:${}${}", master_sheet_name, cl, cl, cat_count),
                    ));
                }

                // 続く列: 各カテゴリのサブカテゴリ (SUB_{lang}_{area_idx}_{cat_idx})
                for (cat_idx, cat_cfg) in area_cfg.categories.iter().enumerate() {
                    let sub_names: Vec<&str> = cat_cfg.sub_categories.iter()
                        .map(|s| s.as_str())
                        .collect();
                    let sub_count = sub_names.len() as u32;
                    if sub_count == 0 { sub_col += 1; continue; }

                    for (r, name) in sub_names.iter().enumerate() {
                        ms.write(r as u32, sub_col, *name).ok();
                    }

                    let cl = col_letter(sub_col);
                    named_ranges.push((
                        format!("SUB_{}_{}_{}", lang_key, area_idx, cat_idx),
                        format!("='{}'!${}$1:${}${}", master_sheet_name, cl, cl, sub_count),
                    ));

                    sub_col += 1;
                }
            }
        } // ms がここでドロップされ、workbook の可変借用が解放される

        // Phase 2: Named Range を workbook に定義する
        for (name, formula) in named_ranges {
            workbook.define_name(&name, &formula)
                .map_err(|e| StoreError::Write {
                    path: format!("named_range:{}", name),
                    source: std::io::Error::other(e.to_string()),
                })?;
        }
    }

    let xlsx_path = out_path
        .map(|p| p.to_path_buf())
        .unwrap_or_else(|| output_dir.join("製品リスト_export.xlsx"));

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
