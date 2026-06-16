import re

JS_FILE = (
    "jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh"
    "/security/products/vulnerabilities/js/vulinfo_search.js"
)

NEW_CODE = (
    "    let fileName;\n"
    "    if (document.location.hostname == \"127.0.0.1\"\n"
    "        || document.location.hostname == \"stg-prv-wrc.scms.jp.ricoh.com\") {\n"
    "        fileName = \"http://127.0.0.1:5500/vuls.ricoh.com/ja/vulinfolist.json?\" + dateParam;\n"
    "    } else {\n"
    "        fileName = \"https://vuls.ricoh.com/ja/vulinfolist.json?\" + dateParam;\n"
    "    }"
)

# 元ファイルをバイナリで読み込んでエンコードを判定
with open(JS_FILE, "rb") as f:
    raw = f.read()

# エンコード判定（BOMなしUTF-8 or Shift-JIS）
try:
    content = raw.decode("utf-8")
    encoding = "utf-8"
except UnicodeDecodeError:
    content = raw.decode("shift-jis")
    encoding = "shift-jis"

print(f"detected encoding: {encoding}")

lines = content.splitlines(keepends=True)

replaced = False
new_lines = []
for line in lines:
    if (
        "https://vuls.ricoh.com/ja/vulinfolist.json" in line
        and "fileName" in line
        and "dateParam" in line
    ):
        new_lines.append(NEW_CODE + "\n")
        replaced = True
    else:
        new_lines.append(line)

if replaced:
    # 元のエンコードのまま書き戻す
    with open(JS_FILE, "w", encoding=encoding) as f:
        f.writelines(new_lines)
    print("OK: vulinfo_search.js patched")
else:
    print("SKIP: target line not found (already patched?)")
