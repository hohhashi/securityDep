//! secAdvisoryTool v2 CLI

use std::path::PathBuf;

use clap::{Parser, Subcommand, ValueEnum};
use secadvisory_core::{config, run_create, run_delete, run_export_products, run_sync_products, run_update};

#[derive(Parser)]
#[command(name = "secAdvisoryTool")]
#[command(version = "0.2.0")]
#[command(about = "アドバイザリ入力シート_v2.xlsx から ja/en JSON ファイルを生成するツール")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Excel を読み込み、ID を自動採番して JSON を新規生成する。
    Create {
        /// アドバイザリ入力シート_v2.xlsx のパス
        #[arg(long, short = 's')]
        source: PathBuf,

        /// JSON ファイルの出力先ルートディレクトリ
        /// （省略時は secAdvisoryTool.toml の output_dir、それも未設定の場合はカレントディレクトリ）
        #[arg(long, short = 'o')]
        output: Option<PathBuf>,
    },
    /// Excel を読み込み、指定した ID の JSON を上書きする。
    Update {
        /// アドバイザリ入力シート_v2.xlsx のパス
        #[arg(long, short = 's')]
        source: PathBuf,

        /// 上書き対象のアドバイザリ ID（例: ricoh-2026-000001）
        #[arg(long, short = 'i')]
        id: String,

        /// JSON ファイルの出力先ルートディレクトリ
        /// （省略時は secAdvisoryTool.toml の output_dir、それも未設定の場合はカレントディレクトリ）
        #[arg(long, short = 'o')]
        output: Option<PathBuf>,
    },
    /// 指定した ID のアドバイザリ JSON を削除し、vulinfolist からも除去する。
    Delete {
        /// 削除対象のアドバイザリ ID（例: ricoh-2026-000006）
        #[arg(long, short = 't')]
        target: String,

        /// JSON ファイルが置かれているルートディレクトリ
        /// （省略時は secAdvisoryTool.toml の output_dir、それも未設定の場合はカレントディレクトリ）
        #[arg(long, short = 'o')]
        output: Option<PathBuf>,
    },
    /// prodinfolist.json の内容を Excel ファイルに出力する。
    ExportProducts {
        /// JSON ファイルが置かれているルートディレクトリ
        /// （省略時は secAdvisoryTool.toml の output_dir、それも未設定の場合はカレントディレクトリ）
        #[arg(long, short = 'o')]
        output: Option<PathBuf>,

        /// 出力先 Excel ファイルのパス
        /// （省略時は {output_dir}/採番済機種リスト_export.xlsx）
        #[arg(long, short = 'd')]
        dest: Option<PathBuf>,
    },
    /// 採番済機種リスト(日)/(英) を読み込み、prodinfolist.json と prodinfo/ を更新する。
    SyncProducts {
        /// 採番済機種リストを含む Excel ファイルのパス
        #[arg(long, short = 's')]
        source: PathBuf,

        /// JSON ファイルの出力先ルートディレクトリ
        #[arg(long, short = 'o')]
        output: Option<PathBuf>,
    },
    /// アドバイザリの ID と脆弱性名の一覧を表示する。
    List {
        /// 表示する言語（ja / en / both）。デフォルト: both（日英混在で表示）
        #[arg(long, short = 'l', default_value = "both")]
        lang: LangFilter,

        /// JSON ファイルが置かれているルートディレクトリ
        #[arg(long, short = 'o')]
        output: Option<PathBuf>,
    },
    /// 最新のアドバイザリ ID と脆弱性名を表示する。
    Latest {
        /// 表示する言語（ja / en / both）。デフォルト: both
        #[arg(long, short = 'l', default_value = "both")]
        lang: LangFilter,

        /// ID のみ表示する（脆弱性名を省略）
        #[arg(long)]
        id_only: bool,

        /// JSON ファイルが置かれているルートディレクトリ
        #[arg(long, short = 'o')]
        output: Option<PathBuf>,
    },
}

/// 表示対象の言語フィルター
#[derive(Clone, ValueEnum)]
enum LangFilter {
    /// 日本語のみ
    Ja,
    /// 英語のみ
    En,
    /// 日英両方（日本語を優先）
    Both,
}

/// パスの区切り文字を / に統一して文字列で返す（Windows の \ 対策）。
fn normalize_path(p: &std::path::Path) -> String {
    p.to_string_lossy().replace('\\', "/")
}

/// 出力先ディレクトリを決定する。
/// 1. --output オプション
/// 2. secAdvisoryTool.toml の output_dir
/// 3. カレントディレクトリ (.)
fn resolve_output(opt: Option<&PathBuf>) -> PathBuf {
    if let Some(p) = opt {
        return p.clone();
    }
    let cfg = config::load();
    if let Some(p) = cfg.output_dir_path() {
        return p;
    }
    PathBuf::from(".")
}

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Create { source, output } => {
            let out = resolve_output(output.as_ref());
            match run_create(source, &out) {
                Ok(r) if r.paths.is_empty() => {
                    eprintln!("警告: 出力するファイルがありませんでした（言語設定を確認してください）。");
                }
                Ok(r) => {
                    println!("ID   : {}", r.id);
                    // JSON ファイルを表示（先頭に「出力 :」）
                    for (i, p) in r.paths.iter().enumerate() {
                        if i == 0 {
                            println!("出力 : {}", normalize_path(p));
                        } else {
                            println!("       {}", normalize_path(p));
                        }
                    }
                    // PDF ファイルも「出力 :」ラベル付きで表示
                    for p in &r.pdf_paths {
                        println!("出力 : {}", normalize_path(p));
                    }
                    for p in &r.list_paths {
                        println!("更新 : {}", normalize_path(p));
                    }
                    for p in &r.prod_paths {
                        println!("更新 : {}", normalize_path(p));
                    }
                }
                Err(e) => {
                    eprintln!("エラー: {}", e);
                    std::process::exit(1);
                }
            }
        }
        Commands::ExportProducts { output, dest } => {
            let out = resolve_output(output.as_ref());
            let dest_path = dest.as_deref();
            match run_export_products(&out, dest_path) {
                Ok(p) => {
                    println!("出力 : {}", normalize_path(&p));
                }
                Err(e) => {
                    eprintln!("エラー: {}", e);
                    std::process::exit(1);
                }
            }
        }
        Commands::SyncProducts { source, output } => {
            let out = resolve_output(output.as_ref());
            match run_sync_products(source, &out) {
                Ok(r) => {
                    println!("処理件数: {} 件", r.row_count);
                    for p in &r.list_paths {
                        println!("更新 : {}", normalize_path(p));
                    }
                }
                Err(e) => {
                    eprintln!("エラー: {}", e);
                    std::process::exit(1);
                }
            }
        }
        Commands::Update { source, id, output } => {
            let out = resolve_output(output.as_ref());
            match run_update(source, id, &out) {
                Ok(r) if r.paths.is_empty() => {
                    eprintln!("警告: 出力するファイルがありませんでした（言語設定を確認してください）。");
                }
                Ok(r) => {
                    println!("ID   : {}", r.id);
                    // JSON ファイルを表示（先頭に「出力 :」）
                    for (i, p) in r.paths.iter().enumerate() {
                        if i == 0 {
                            println!("出力 : {}", normalize_path(p));
                        } else {
                            println!("       {}", normalize_path(p));
                        }
                    }
                    // PDF ファイルも「出力 :」ラベル付きで表示
                    for p in &r.pdf_paths {
                        println!("出力 : {}", normalize_path(p));
                    }
                    for p in &r.list_paths {
                        println!("更新 : {}", normalize_path(p));
                    }
                    for p in &r.prod_paths {
                        println!("更新 : {}", normalize_path(p));
                    }
                }
                Err(e) => {
                    eprintln!("エラー: {}", e);
                    std::process::exit(1);
                }
            }
        }
        Commands::Delete { target, output } => {
            let out = resolve_output(output.as_ref());
            // 欠番にするか対話プロンプトで確認する
            let make_gap = {
                use std::io::{self, Write};
                println!("削除後、この ID を欠番にしますか？");
                println!("  y = 欠番にする（以後この番号はスキップされる）");
                println!("  N = 欠番にしない（次回の採番でこの番号が再利用される）[デフォルト]");
                print!("選択 (y/N): ");
                io::stdout().flush().ok();
                let mut line = String::new();
                io::stdin().read_line(&mut line).ok();
                line.trim().eq_ignore_ascii_case("y")
            };
            println!("→ {}", if make_gap { "欠番にする" } else { "欠番にしない（番号を再利用）" });
            match run_delete(target, &out, make_gap) {
                Ok(r) if r.deleted.is_empty() && r.updated_lists.is_empty() && r.updated_prodinfo.is_empty() => {
                    eprintln!(
                        "警告: ID '{}' に対応するファイルが見つかりませんでした。",
                        r.id
                    );
                }
                Ok(r) => {
                    for p in &r.deleted {
                        println!("削除 : {}", normalize_path(p));
                    }
                    for p in &r.updated_lists {
                        println!("更新 : {}", normalize_path(p));
                    }
                    for p in &r.updated_prodinfo {
                        println!("更新 : {}", normalize_path(p));
                    }
                    if make_gap {
                        println!("欠番 : {} を欠番として記録しました（再利用されません）", r.id);
                    } else {
                        println!("採番 : {} は次回の create で再利用されます", r.id);
                    }
                }
                Err(e) => {
                    eprintln!("エラー: {}", e);
                    std::process::exit(1);
                }
            }
        }
        Commands::List { lang, output } => {
            let out = resolve_output(output.as_ref());
            let entries = load_entries(&out, lang);
            if entries.is_empty() {
                eprintln!("アドバイザリが見つかりませんでした。");
            } else {
                for (id, title) in &entries {
                    println!("{} : {}", id, title);
                }
            }
        }
        Commands::Latest { lang, id_only, output } => {
            let out = resolve_output(output.as_ref());
            let entries = load_entries(&out, lang);
            match entries.first() {
                Some((id, title)) => {
                    if *id_only {
                        println!("{}", id);
                    } else {
                        println!("{} : {}", id, title);
                    }
                }
                None => eprintln!("アドバイザリが見つかりませんでした。"),
            }
        }
    }
}

/// `vulinfolist.json` から (id, title) 一覧を読み込む。
///
/// `LangFilter::Both` の場合: ja を読み、なければ en を読む（マージして重複排除）。
/// vulinfolist は先頭が最新なのでそのまま返す。
fn load_entries(output_dir: &PathBuf, lang: &LangFilter) -> Vec<(String, String)> {
    match lang {
        LangFilter::Ja => read_vulinfolist(output_dir, "ja"),
        LangFilter::En => read_vulinfolist(output_dir, "en"),
        LangFilter::Both => {
            // ja を基準に取り込み、en にしかないものを末尾に追加
            let ja = read_vulinfolist(output_dir, "ja");
            let en = read_vulinfolist(output_dir, "en");
            let ja_ids: std::collections::HashSet<String> =
                ja.iter().map(|(id, _)| id.clone()).collect();
            let mut result = ja;
            for (id, title) in en {
                if !ja_ids.contains(&id) {
                    result.push((id, title));
                }
            }
            result
        }
    }
}

fn read_vulinfolist(output_dir: &PathBuf, lang: &str) -> Vec<(String, String)> {
    let path = output_dir.join(lang).join("vulinfolist.json");
    let text = match std::fs::read_to_string(&path) {
        Ok(t) => t,
        Err(_) => return Vec::new(),
    };
    let arr: Vec<serde_json::Value> = match serde_json::from_str(&text) {
        Ok(v) => v,
        Err(_) => return Vec::new(),
    };
    arr.into_iter()
        .filter_map(|v| {
            let id = v.get("id")?.as_str()?.to_string();
            let title = v.get("title")?.as_str()?.to_string();
            Some((id, title))
        })
        .collect()
}
