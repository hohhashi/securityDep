//! アドバイザリ ID の自動採番。
//!
//! 出力先ディレクトリ配下に既存の `ricoh-YYYY-NNNNNN.json` が何件あるかを
//! 走査し、同じ年内で最大番号 + 1 を返す。
//!
//! 走査するパス:
//!   `{output_dir}/ja/vulinfo/{YYYY}/ricoh-{YYYY}-*.json`
//!   `{output_dir}/en/vulinfo/{YYYY}/ricoh-{YYYY}-*.json`
//! ja / en のどちらかが存在すれば十分（両方重複カウントしない）。

use std::collections::HashSet;
use std::path::Path;

/// `{output_dir}/gaps.json` に欠番 ID を追記する。
///
/// ファイルが存在しない場合は新規作成する。
/// 既に記録済みの ID の場合は何もしない。
pub fn record_gap(output_dir: &Path, id: &str) -> std::io::Result<()> {
    let path = output_dir.join("gaps.json");
    let mut ids: Vec<String> = if path.exists() {
        let text = std::fs::read_to_string(&path)?;
        serde_json::from_str(&text).unwrap_or_default()
    } else {
        Vec::new()
    };
    if !ids.contains(&id.to_string()) {
        ids.push(id.to_string());
        let text = serde_json::to_string_pretty(&ids)
            .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))?;
        std::fs::write(&path, text)?;
    }
    Ok(())
}

/// `{output_dir}` 配下から使用済みの番号をすべて収集して返す。
///
/// 収集元:
///   1. `ja/vulinfolist.json` / `en/vulinfolist.json` に記載された ID
///   2. `ja/vulinfo/{year}/` / `en/vulinfo/{year}/` のファイル名
///   3. `gaps.json` に記録された欠番 ID
fn collect_used_nums(output_dir: &Path, year: &str) -> HashSet<u32> {
    let mut nums = HashSet::new();
    let prefix = format!("ricoh-{}-", year);

    // 1. vulinfolist.json から ID を収集（既存データが最も確実）
    for lang in &["ja", "en"] {
        let list_path = output_dir.join(lang).join("vulinfolist.json");
        if let Ok(text) = std::fs::read_to_string(&list_path) {
            if let Ok(arr) = serde_json::from_str::<Vec<serde_json::Value>>(&text) {
                for entry in arr {
                    if let Some(id) = entry.get("id").and_then(|v| v.as_str()) {
                        if let Some(num_str) = id.strip_prefix(&prefix) {
                            if let Ok(n) = num_str.parse::<u32>() {
                                nums.insert(n);
                            }
                        }
                    }
                }
            }
        }
    }

    // 2. ディレクトリを走査して現存するファイルの番号を収集
    for lang in &["ja", "en"] {
        let dir = output_dir.join(lang).join("vulinfo").join(year);
        let entries = match std::fs::read_dir(&dir) {
            Ok(e) => e,
            Err(_) => continue,
        };
        for entry in entries.flatten() {
            let name = entry.file_name();
            let name = name.to_string_lossy();
            if let Some(stem) = name.strip_suffix(".json") {
                if let Some(num_str) = stem.strip_prefix(&prefix) {
                    if let Ok(n) = num_str.parse::<u32>() {
                        nums.insert(n);
                    }
                }
            }
        }
    }

    // 3. gaps.json から欠番を収集
    let gaps_path = output_dir.join("gaps.json");
    if let Ok(text) = std::fs::read_to_string(&gaps_path) {
        if let Ok(ids) = serde_json::from_str::<Vec<String>>(&text) {
            for id in ids {
                if let Some(num_str) = id.strip_prefix(&prefix) {
                    if let Ok(n) = num_str.parse::<u32>() {
                        nums.insert(n);
                    }
                }
            }
        }
    }

    nums
}

/// 次の ID を採番して返す。
///
/// - `year`       : `publishedAt` から取得した4桁の年文字列（例: `"2026"`）
/// - `output_dir` : JSON ファイルの出力先ルートディレクトリ
///
/// 現存するファイルの ID と削除済み ID の両方をスキップする。
/// 戻り値: `ricoh-YYYY-NNNNNN` 形式の文字列
pub fn next_id(output_dir: &Path, year: &str) -> String {
    let used = collect_used_nums(output_dir, year);
    let next_num = (1u32..).find(|n| !used.contains(n)).unwrap_or(1);
    format!("ricoh-{}-{:06}", year, next_num)
}

