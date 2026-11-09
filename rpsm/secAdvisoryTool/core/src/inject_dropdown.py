#!/usr/bin/env python3
"""
inject_dropdown.py -- アドバイザリ入力シートに事業/カテゴリ/サブカテゴリの
3段連動プルダウンを埋め込むスクリプト。

【方針】
  元のxlsxを ZIP として扱い、変更が必要なファイルだけ差し替える。
  openpyxlには頼らず、XML を直接操作する。
  これにより xr:uid等のMicrosoft拡張属性・extLstブロックが消えず、
  既存テーブルや書式が壊れない。

使い方:
    python3 inject_dropdown.py <input.xlsx> <output.xlsx> <json_config>

json_config の形式 (JSON文字列):
[
  {
    "lang": "ja",
    "area": "オフィスプロダクツ",
    "categories": [
      { "name": "デジタル複合機", "sub_categories": ["A4モデル", "A3モデル"] },
      ...
    ]
  },
  ...
]

終了コード:
  0: 成功 (stdout に "OK:<output_path>")
  1: エラー (stderr にメッセージ)
"""
import sys
import json
import zipfile
import re
import io

# ─── XML ユーティリティ ───────────────────────────────────────────────────────

def xml_escape(s):
    return (s.replace('&', '&amp;')
             .replace('<', '&lt;')
             .replace('>', '&gt;')
             .replace('"', '&quot;')
             .replace("'", '&apos;'))

def xml_escape_text(s):
    return (s.replace('&', '&amp;')
             .replace('<', '&lt;')
             .replace('>', '&gt;'))

def col_letter(n):
    """0始まりの列インデックス → Excel列文字 (A, B, ..., Z, AA, ...)"""
    result = ''
    n += 1
    while n > 0:
        n -= 1
        result = chr(ord('A') + n % 26) + result
        n //= 26
    return result

# ─── マスタシート XML 生成 ────────────────────────────────────────────────────

def build_master_xml_and_ranges(sheet_name, lang_key, areas):
    """
    マスタシートの XML と Named Range リストを返す。

    列レイアウト:
      A: 事業一覧
      B〜: 各事業のカテゴリ一覧
      その後: 各カテゴリのサブカテゴリ
    """
    cols = []
    named_ranges = []  # (name, col_0based, length)

    # A列: 事業
    area_names = [a['area'] for a in areas]
    cols.append(area_names)
    if area_names:
        named_ranges.append((f'AREA_{lang_key}', 0, len(area_names)))

    # B列〜: カテゴリ
    cat_col_start = 1
    for ai, area in enumerate(areas):
        cat_names = [c['name'] for c in area.get('categories', [])]
        cols.append(cat_names)
        if cat_names:
            named_ranges.append((f'CAT_{lang_key}_{ai}', cat_col_start + ai, len(cat_names)))

    # サブカテゴリ列
    sub_col = cat_col_start + len(areas)
    for ai, area in enumerate(areas):
        for ci, cat in enumerate(area.get('categories', [])):
            sub_names = cat.get('sub_categories', [])
            cols.append(sub_names)
            if sub_names:
                named_ranges.append((f'SUB_{lang_key}_{ai}_{ci}', sub_col, len(sub_names)))
            sub_col += 1

    max_row = max((len(c) for c in cols), default=0)

    xml = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
           '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">\n'
           '<sheetData>\n')

    for row_i in range(max_row):
        xml += f'<row r="{row_i + 1}">\n'
        for col_i, col_data in enumerate(cols):
            if row_i < len(col_data) and col_data[row_i]:
                cell_ref = f'{col_letter(col_i)}{row_i + 1}'
                val = xml_escape(col_data[row_i])
                xml += f'<c r="{cell_ref}" t="inlineStr"><is><t>{val}</t></is></c>\n'
        xml += '</row>\n'

    xml += '</sheetData>\n</worksheet>'
    return xml, named_ranges

# ─── DataValidation XML 生成 ─────────────────────────────────────────────────

def build_dv_xml(lang_key, max_row=1000):
    """
    製品リストシート用の dataValidations XML ブロックを生成する。
    B=事業, C=カテゴリ, D=サブカテゴリ
    """
    # B列: 事業
    dv_area = (
        f'<dataValidation type="list" allowBlank="1" '
        f'showInputMessage="1" showErrorMessage="1" sqref="B2:B{max_row}">'
        f'<formula1>INDIRECT(&quot;AREA_{lang_key}&quot;)</formula1>'
        f'</dataValidation>'
    )

    # C列: カテゴリ（事業連動）
    cat_f = (
        f'INDIRECT(&quot;CAT_{lang_key}_&quot;'
        f'&amp;TEXT(MATCH(B2,INDIRECT(&quot;AREA_{lang_key}&quot;),0)-1,&quot;0&quot;))'
    )
    dv_cat = (
        f'<dataValidation type="list" allowBlank="1" '
        f'showInputMessage="1" showErrorMessage="1" sqref="C2:C{max_row}">'
        f'<formula1>{cat_f}</formula1>'
        f'</dataValidation>'
    )

    # D列: サブカテゴリ（事業+カテゴリ連動）
    sub_f = (
        f'INDIRECT(&quot;SUB_{lang_key}_&quot;'
        f'&amp;TEXT(MATCH(B2,INDIRECT(&quot;AREA_{lang_key}&quot;),0)-1,&quot;0&quot;)'
        f'&amp;&quot;_&quot;'
        f'&amp;TEXT(MATCH(C2,INDIRECT(&quot;CAT_{lang_key}_&quot;'
        f'&amp;TEXT(MATCH(B2,INDIRECT(&quot;AREA_{lang_key}&quot;),0)-1,&quot;0&quot;)),0)-1,&quot;0&quot;))'
    )
    dv_sub = (
        f'<dataValidation type="list" allowBlank="1" '
        f'showInputMessage="1" showErrorMessage="1" sqref="D2:D{max_row}">'
        f'<formula1>{sub_f}</formula1>'
        f'</dataValidation>'
    )

    return f'<dataValidations count="3">\n{dv_area}\n{dv_cat}\n{dv_sub}\n</dataValidations>'


def inject_dv_into_sheet(sheet_xml, dv_xml):
    """既存シート XML に DV ブロックを挿入する（既存 DV は除去）。

    OOXML CT_Worksheet スキーマの要素順序:
      sheetData > phoneticPr > conditionalFormatting > dataValidations
      > hyperlinks > printOptions > pageMargins > pageSetup
      > headerFooter > ... > tableParts > ...

    dataValidations は phoneticPr の後かつ pageMargins の前に挿入する。
    """
    # 既存 dataValidations を除去（標準形式）
    cleaned = re.sub(r'<dataValidations\b[^>]*>.*?</dataValidations>', '', sheet_xml, flags=re.DOTALL)

    # 挿入位置を決定（スキーマ順序に従う）
    # 優先度: <pageMargins の前 > <pageSetup の前 > <tableParts の前 > </worksheet> の前
    inserted = False
    for anchor in ('<pageMargins', '<pageSetup', '<tableParts', '</worksheet>'):
        if anchor in cleaned:
            cleaned = cleaned.replace(anchor, f'{dv_xml}\n{anchor}', 1)
            inserted = True
            break
    if not inserted:
        cleaned += f'\n{dv_xml}'
    return cleaned

# ─── workbook.xml 操作 ───────────────────────────────────────────────────────

def get_max_rid(rels_xml):
    nums = [int(m) for m in re.findall(r'Id="rId(\d+)"', rels_xml)]
    return max(nums, default=0)

def get_max_sheet_id(workbook_xml):
    nums = [int(m) for m in re.findall(r'sheetId="(\d+)"', workbook_xml)]
    return max(nums, default=0)

def inject_workbook_entries(workbook_xml, new_sheets, named_ranges):
    """
    workbook.xml にシートエントリと definedNames を追加する。
    new_sheets: list of (name, rid, sheet_id)
    named_ranges: list of (name, formula)
    """
    result = workbook_xml

    for name, rid, sid in new_sheets:
        entry = f'<sheet name="{xml_escape(name)}" sheetId="{sid}" state="hidden" r:id="{rid}"/>'
        result = result.replace('</sheets>', f'{entry}\n</sheets>', 1)

    if named_ranges:
        dn_xml = ''.join(
            # formula は呼び出し元で既にアポストロフィをエスケープ済み。
            # xml_escape_text は & < > のみ変換（アポストロフィは触らない）
            f'<definedName name="{xml_escape(n)}">{xml_escape_text(f)}</definedName>'
            for n, f in named_ranges
        )
        if '<definedNames>' in result:
            # 既存の _マスタ_ 定義を上書き
            result = re.sub(
                r'<definedNames>.*?</definedNames>',
                f'<definedNames>{dn_xml}</definedNames>',
                result, flags=re.DOTALL
            )
        else:
            # calcPr より前、なければ </workbook> より前に挿入
            insert_before = '<calcPr' if '<calcPr' in result else '</workbook>'
            result = result.replace(insert_before,
                                    f'<definedNames>{dn_xml}</definedNames>{insert_before}', 1)
    return result


def inject_rels(rels_xml, new_rels):
    """workbook.xml.rels に Relationship エントリを追加する。"""
    result = rels_xml
    for rid, target in new_rels:
        entry = (
            f'<Relationship Id="{rid}" '
            f'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" '
            f'Target="{target}"/>'
        )
        result = result.replace('</Relationships>', f'{entry}\n</Relationships>', 1)
    return result


def inject_content_types(ct_xml, new_parts):
    """[Content_Types].xml に Override エントリを追加する。"""
    result = ct_xml
    for part in new_parts:
        if part not in result:
            entry = (
                f'<Override PartName="{part}" '
                f'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
            )
            result = result.replace('</Types>', f'{entry}\n</Types>', 1)
    return result

# ─── ZIP のパース ─────────────────────────────────────────────────────────────

def parse_sheet_map(workbook_xml, rels_xml):
    """workbook.xml + rels から {sheet_name: zip_path} を返す。"""
    rel_map = {}
    for m in re.finditer(r'<Relationship\b([^>]+)/>', rels_xml):
        attrs = m.group(1)
        rid_m = re.search(r'Id="([^"]+)"', attrs)
        tgt_m = re.search(r'Target="([^"]+)"', attrs)
        if rid_m and tgt_m:
            rel_map[rid_m.group(1)] = tgt_m.group(1)

    sheet_map = {}
    for m in re.finditer(r'<sheet\b([^>]+)/>', workbook_xml):
        attrs = m.group(1)
        name_m = re.search(r'\bname="([^"]+)"', attrs)
        rid_m  = re.search(r'r:id="([^"]+)"', attrs) or re.search(r'\bid="([^"]+)"', attrs)
        if name_m and rid_m:
            rid = rid_m.group(1)
            target = rel_map.get(rid, '')
            # target は "../worksheets/sheet4.xml" のような相対パスか絶対パス
            target = target.lstrip('/')
            if target.startswith('worksheets/'):
                zip_path = f'xl/{target}'
            elif '/' not in target:
                zip_path = f'xl/worksheets/{target}'
            else:
                zip_path = target
            sheet_map[name_m.group(1)] = zip_path
    return sheet_map

# ─── メイン ──────────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) != 4:
        print(f'Usage: {sys.argv[0]} <input.xlsx> <output.xlsx> <json_config>',
              file=sys.stderr)
        sys.exit(1)

    input_path, output_path, config_json = sys.argv[1], sys.argv[2], sys.argv[3]

    try:
        config = json.loads(config_json)
    except json.JSONDecodeError as e:
        print(f'JSON設定の解析に失敗しました: {e}', file=sys.stderr)
        sys.exit(1)

    # 言語ごとにグループ化
    by_lang = {}
    for entry in config:
        lang = entry.get('lang', 'ja')
        by_lang.setdefault(lang, []).append(entry)

    with zipfile.ZipFile(input_path, 'r') as zin:
        # 必要ファイルを読み込む
        workbook_xml = zin.read('xl/workbook.xml').decode('utf-8')
        rels_xml     = zin.read('xl/_rels/workbook.xml.rels').decode('utf-8')
        ct_xml       = zin.read('[Content_Types].xml').decode('utf-8')

        sheet_map = parse_sheet_map(workbook_xml, rels_xml)

        sheet_ja_path = sheet_map.get('製品リスト(日)')
        sheet_en_path = sheet_map.get('製品リスト(英)')
        if not sheet_ja_path:
            print("シート '製品リスト(日)' が見つかりません", file=sys.stderr)
            sys.exit(1)
        if not sheet_en_path:
            print("シート '製品リスト(英)' が見つかりません", file=sys.stderr)
            sys.exit(1)

        sheet_ja_xml = zin.read(sheet_ja_path).decode('utf-8')
        sheet_en_xml = zin.read(sheet_en_path).decode('utf-8')

        cur_max_rid      = get_max_rid(rels_xml)
        cur_max_sheet_id = get_max_sheet_id(workbook_xml)

        # マスタシートを構築
        master_files   = {}   # zip_path -> xml_bytes
        new_sheet_entries = []
        new_rels          = []
        new_ct_parts      = []
        all_named_ranges  = []  # (name, formula)

        for i, (lang_key, areas) in enumerate(by_lang.items()):
            master_name = f'_マスタ_{lang_key}'
            sheet_id    = cur_max_sheet_id + 1 + i
            rid         = f'rId{cur_max_rid + 1 + i}'
            rel_target  = f'worksheets/sheet_master_{lang_key}.xml'
            zip_path    = f'xl/worksheets/sheet_master_{lang_key}.xml'

            master_xml, named_ranges = build_master_xml_and_ranges(master_name, lang_key, areas)

            for rng_name, col_idx, length in named_ranges:
                cl = col_letter(col_idx)
                # OOXML: definedName のテキストは = なし、アポストロフィは &apos; にエスケープ
                escaped_name = master_name.replace("'", "&apos;")
                formula = f"'{escaped_name}'!${cl}$1:${cl}${length}"
                all_named_ranges.append((rng_name, formula))

            master_files[zip_path] = master_xml.encode('utf-8')
            new_sheet_entries.append((master_name, rid, sheet_id))
            new_rels.append((rid, rel_target))
            new_ct_parts.append(f'/xl/worksheets/sheet_master_{lang_key}.xml')

        # DV を製品リストシートに差し込む
        dv_ja = build_dv_xml('ja') if 'ja' in by_lang else None
        dv_en = build_dv_xml('en') if 'en' in by_lang else None

        new_sheet_ja = inject_dv_into_sheet(sheet_ja_xml, dv_ja) if dv_ja else sheet_ja_xml
        new_sheet_en = inject_dv_into_sheet(sheet_en_xml, dv_en) if dv_en else sheet_en_xml

        # workbook.xml / rels / content_types を更新
        new_workbook = inject_workbook_entries(workbook_xml, new_sheet_entries, all_named_ranges)
        new_rels_xml = inject_rels(rels_xml, new_rels)
        new_ct_xml   = inject_content_types(ct_xml, new_ct_parts)

        # 差し替えマップを構築
        overrides = {
            'xl/workbook.xml':             new_workbook.encode('utf-8'),
            'xl/_rels/workbook.xml.rels':  new_rels_xml.encode('utf-8'),
            '[Content_Types].xml':         new_ct_xml.encode('utf-8'),
            sheet_ja_path:                 new_sheet_ja.encode('utf-8'),
            sheet_en_path:                 new_sheet_en.encode('utf-8'),
        }
        overrides.update(master_files)

        # 新しい ZIP を書き出す（元のエントリをそのままコピー + 差し替え + 新規追加）
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, 'w', zipfile.ZIP_DEFLATED) as zout:
            # 元ファイルのエントリをコピー
            for item in zin.infolist():
                name = item.filename
                if name in overrides:
                    zout.writestr(item, overrides.pop(name))
                else:
                    zout.writestr(item, zin.read(name))

            # 新規ファイル（マスタシート）を追加
            for path, data in overrides.items():
                zout.writestr(path, data)

    with open(output_path, 'wb') as f:
        f.write(buf.getvalue())

    print(f'OK:{output_path}')


if __name__ == '__main__':
    main()
