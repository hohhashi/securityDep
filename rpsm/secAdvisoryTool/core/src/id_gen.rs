//! アドバイザリ ID の自動採番。
//!
//! 出力先ディレクトリ配下に既存の `ricoh-YYYY-NNNNNN.json` が何件あるかを
//! 走査し、同じ年内で最大番号 + 1 を返す。
//!
//! 走査するパス:
//!   `{output_dir}/ja/vulinfo/{YYYY}/ricoh-{YYYY}-*.json`
//!   `{output_dir}/en/vulinfo/{YYYY}/ricoh-{YYYY}-*.json`
//! ja / en のどちらかが存在すれば十分（両方重複カウントしない）。
//!
//! 欠番管理:
//!   `{output_dir}/deleted_ids.txt` に記録された ID は採番でスキップされる。

use std::collections::HashSet;
use std::path::Path;

/// `{output_dir}` 配下から使用済みの番号をすべて収集して返す。
///
/// 収集元:
///   0. `deleted_ids.txt` に記録された欠番 ID
///   1. `ja/vulinfolist.json` / `en/vulinfolist.json` に記載された ID
///   2. `ja/vulinfo/{year}/` / `en/vulinfo/{year}/` のファイル名
fn collect_used_nums(output_dir: &Path, year: &str) -> HashSet<u32> {
    let mut nums = HashSet::new();
    let prefix = format!("ricoh-{}-", year);

    // 0. 欠番リスト（deleted_ids.txt）をスキップ対象に追加
    let gap_path = output_dir.join("deleted_ids.txt");
    if let Ok(text) = std::fs::read_to_string(&gap_path) {
        for line in text.lines() {
            let line = line.trim();
            if let Some(num_str) = line.strip_prefix(&prefix) {
                if let Ok(n) = num_str.parse::<u32>() {
                    nums.insert(n);
                }
            }
        }
    }

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

    nums
}

/// 次の ID を採番して返す。
///
/// - `year`       : `publishedAt` から取得した4桁の年文字列（例: `"2026"`）
/// - `output_dir` : JSON ファイルの出力先ルートディレクトリ
///
/// 現存するファイルの最大番号 + 1 を採番する。
/// `deleted_ids.txt` に記録された欠番はスキップされる。
/// 戻り値: `ricoh-YYYY-NNNNNN` 形式の文字列
pub fn next_id(output_dir: &Path, year: &str) -> String {
    let used = collect_used_nums(output_dir, year);
    let next_num = used.iter().copied().max().unwrap_or(0) + 1;
    format!("ricoh-{}-{:06}", year, next_num)
}
