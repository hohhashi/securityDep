# secAdvisoryTool（最初のサンプル / コアロジック + CLI版）

Excelの脆弱性情報テーブルから JSON（`vulinfolist.json` 互換形式）を生成・更新・削除し、
さらにその1件分をブラウザでレンダリングしてPDFに変換するツールです。

このリポジトリは「まず基本系列が通るサンプル」として、**コアロジック（`core`）と
CLI（`cli`）のみ**を実装したものです。Tauri/Vueによる GUI 部分はまだ含まれていません
（次のステップで `core` をそのまま使って追加する想定です）。

## フォルダ構成

```
secAdvisoryTool/
├─ Cargo.toml              … cargoワークスペース定義
├─ core/                   … コアロジック（secadvisory-core クレート）
│  ├─ src/
│  │  ├─ lib.rs            … create/update/delete のオーケストレーション
│  │  ├─ config.rs         … ./secAdvisoryTool.toml の読み込み
│  │  ├─ id_gen.rs         … create時のID自動採番（ricoh-YYYY-NNNNNN）
│  │  ├─ excel.rs          … Excelのテーブル（ListObject）をテーブル名で検索して読込
│  │  ├─ model.rs          … vulinfolist.json のデータモデル
│  │  ├─ store.rs          … vulinfolist.json の読み書き
│  │  ├─ server.rs         … PDF化・GUI表示用のローカルHTTPサーバー（127.0.0.1）
│  │  └─ pdf.rs            … ローカルのChrome/Edge/ChromiumでURLをPDF化
│  ├─ assets/              … report.html/js/css（一覧）, detail.html/js/css（1件詳細）
│  └─ examples/
│     ├─ table_probe.rs    … Excelファイル内のテーブル名一覧を確認する診断用ツール
│     └─ serve_test.rs     … ローカルサーバー単体の動作確認用
├─ cli/                    … secAdvisoryTool バイナリ（CLI本体）
└─ templates/
   └─ sample_advisory_template.xlsx  … すぐ試せるサンプルExcel
```

## ビルド方法

Rust（1.75以上）と Cargo が必要です。

```sh
cargo build --release
# バイナリは target/release/secAdvisoryTool に生成されます
```

## 初回セットアップ

ツールを使うフォルダ（作業ディレクトリ）に移動し、`init` サブコマンドで雛形を生成します。

```sh
cd /path/to/your/workdir
/path/to/target/release/secAdvisoryTool init
```

`./secAdvisoryTool.toml`（設定ファイル）と `./json_data/`（JSONの蓄積先）が作成されます。
`secAdvisoryTool.toml` の中身：

```toml
json_data_dir = "./json_data"

[tables]
parent = "AdvisoryMain"

[[tables.children]]
name = "AffectedProducts"
json_key = "affectedProducts"
link_column = "AdvisoryID"
```

- `secAdvisoryTool.toml` は**常にカレントディレクトリ固定**です（場所を指定するオプションはありません）。
- `json_data_dir` を書き換えれば、JSONの蓄積先を変更できます。
- 子テーブルが複数ある場合は `[[tables.children]]` を増やしてください。

## Excelテンプレートの作り方

`templates/sample_advisory_template.xlsx` を開いて編集してください。中身は以下の規約です。

**親テーブル（`AdvisoryMain`）** … 1回の create / update 実行につき、**データ行は必ず1行**
（1回の実行＝1件の脆弱性情報の作成・更新、という設計のため）。

| 列名 | 必須 | 説明 |
|---|---|---|
| title | ◯ | タイトル |
| importance | - | `Important` を入れると「重要」マークがつく |
| severity | - | `Critical` / `High` / `Medium` / `Low` など |
| cve | - | CVE番号をカンマ区切りで（例: `CVE-2026-12345, CVE-2026-12346`）。URLはNVDのパターンから自動生成 |
| jvn | - | JVN番号をカンマ区切り。`JVN#`, `JVNVU#`, `JVNDB-` の3パターンはURLを自動生成、それ以外は空欄になる |
| publishedAt | - | `2026-01-01` 形式（タイムゾーン省略時は `+09:00` を自動付加） |
| updatedAt | - | 同上 |
| AdvisoryID（conf の `link_column` と同名） | 子テーブルがある場合は実質必須 | 子テーブルと紐付けるための**このExcelファイル内だけで使うローカルなキー**（最終的なJSONの `id` とは無関係。`id` はツールが自動採番するか、update時はCLIで指定したIDを使う） |

**子テーブル（例: `AffectedProducts`）** … N:M関係（製品×バージョン×発生条件など）を表現する。
列名は自由（`AdvisoryID` 以外の列はそのままJSONのフィールド名になる）。複数行あってよい。
`AdvisoryID` 列の値が親テーブルの行と一致する行だけが、その脆弱性情報に紐付けられる。

> **Excelファイルの形式について**: テーブル（ListObject）機能は `.xlsx` / `.xlsm` 限定です。
> 古い `.xls` 形式では使えないため、`.xlsx` で保存してください。
>
> **openpyxl等でテストファイルを自動生成する場合の注意**: openpyxlが書き出すテーブルの
> リレーションシップが絶対パス形式になっており、calamine（Excel読み込みに使用しているクレート）
> がテーブルを検出できないことがあります。実際にMicrosoft Excel / LibreOffice Calcで
> 作成・保存したファイルではこの問題は発生しません。

## 使い方

```sh
# 新規追加（IDは自動採番される。ricoh-{UTC年}-{6桁連番、年ごとにリセット}）
secAdvisoryTool create --source Sample.xlsx

# 既存IDのレコードをExcelの内容で作り直す（= 内部的には delete + create(指定ID)）
secAdvisoryTool update --source Sample.xlsx --target ricoh-2026-000001

# 指定IDのレコードを削除（PDFは生成されない）
secAdvisoryTool delete --target ricoh-2026-000001
```

`--source`（入力データの起点）と`--target`（操作対象のID）は対になる名前にしています
（create には `--target` が無く、delete には `--source` が無い）。

実行すると、以下が出力されます。

- `<json_data_dir>/vulinfolist.json` … 確定データの蓄積先（蓄積され続ける。出力先はこの1箇所のみ）
- `./<id>_<実行時のタイムスタンプ>.pdf` … create/update時のみ、カレントフォルダに出力。
  例: `ricoh-2026-000001_20260626_144501.pdf`。実行ごとに日時を含むファイル名にしているため、
  同じIDで何度実行してもファイル名が重複しない（前回のPDFをPDFビューアで開いたままでも
  上書きエラーにならない）。

### JSONファイルが他のプログラムで開かれている場合

`vulinfolist.json` をExcelやテキストエディタなどで開いたまま create / update / delete を
実行すると、書き込み（保存）の段階でエラーになり、その旨のメッセージが表示されます
（一時ファイルへ書き込んでから本体にrenameする方式で、このrenameが失敗することを検出しています）。
ファイルを閉じてから再実行してください。

## PDF生成の前提条件

PDF生成は、ローカルにインストールされている **Google Chrome / Microsoft Edge / Chromium**
をヘッドレスモードで起動して行います（`--headless=new --print-to-pdf`）。
Windowsであれば標準でEdgeが入っているため、追加インストール無しで動作するはずです。
ブラウザが見つからない場合は、JSON生成までは成功し、PDF生成の手前でエラーになります
（エラーメッセージにその旨が表示されます）。

毎回ブラウザ起動ごとに専用の一時プロファイル（`--user-data-dir`）を使うようにしています。
これは、すでに通常のウィンドウでChrome/Edgeを起動している状態だと、既定プロファイルでは
シングルインスタンス機構により処理が既存プロセスへ転送されてしまい、相対パスの解決基準が
食い違って「実際は成功しているのにエラーと判定される」ことがあるためです。

## 動作確認済みの内容

このサンプルは以下を実際に動かして確認しています（JSON生成部分のみ。PDF化は検証環境に
ブラウザが無かったため、ブラウザ未検出時のエラーハンドリングのみ確認済みです）。

- `templates/` のテンプレートを元にしたExcelからの create（ID自動採番、CVE/JVNのURL自動生成、
  子テーブルからの `affectedProducts` 組み立て）
- 2件目の create（IDが連番で増えること）
- update（指定IDのレコードが削除され、新しい内容で先頭に作り直されること）
- delete（指定IDのレコードが削除され、PDFは生成されないこと）
- 存在しないIDへの delete / update がエラーになること
- 親テーブルのデータ行が2行以上あるとエラーになること（1回の実行＝1件、の制約）
- confファイルが無いと、`init` での生成方法を案内するエラーになること

## まだ未実装・今後の課題

- **Tauri / Vue によるGUI**: 今回はCLIのみ。`core`（`secadvisory-core`）クレートをそのまま
  Tauriのコマンドから呼び出す形で追加する想定です。GUIから渡すパラメータはCLIと同じ
  （操作種別・Excelファイル・ID）になります。
- 本番のリコーのページ（`vulinfo_search.js` / `vulnerabilities.html`）の流用は未着手です。
  `assets/report.js` のコメントに記載の通り、データ取得元（`/vulinfolist.json`）と
  DOM構造の考え方は揃えてあるので、後から差し替えやすいようにしてあります。
- JVNのURL自動生成は3パターン（`JVN#`, `JVNVU#`, `JVNDB-`）のみ対応。それ以外の形式は
  URL空欄になります。
- Excelの列名とJSONキー名のマッピング設定（列名を自由に変えたい場合の仕組み）は
  まだ無く、列名は固定（`title`, `importance`, `severity`, `cve`, `jvn`, `publishedAt`,
  `updatedAt`、および `link_column` で指定した名前）です。
