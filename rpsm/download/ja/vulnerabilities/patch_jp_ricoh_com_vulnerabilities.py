import os

# move to the directory where this script is located
os.chdir(os.path.dirname(os.path.abspath(__file__)))

# -----------------------------------------------
# common
# -----------------------------------------------

def read_file(path):
    with open(path, 'rb') as f:
        raw = f.read()
    try:
        return raw.decode('utf-8'), 'utf-8'
    except UnicodeDecodeError:
        return raw.decode('shift-jis'), 'shift-jis'

def write_file(path, content, encoding):
    with open(path, 'w', encoding=encoding) as f:
        f.write(content)

def patch_file(path, condition_fn, new_code):
    if not os.path.exists(path):
        print(f'NOT FOUND: {path}')
        return
    content, encoding = read_file(path)
    lines = content.splitlines(keepends=True)
    replaced = False
    new_lines = []
    for line in lines:
        if condition_fn(line):
            new_lines.append(new_code + '\n')
            replaced = True
        else:
            new_lines.append(line)
    if replaced:
        write_file(path, ''.join(new_lines), encoding)
        print(f'OK: {path}')
    else:
        print(f'SKIP: {path} (target line not found)')

# -----------------------------------------------
# patch vulinfo_search.js
# -----------------------------------------------

patch_file(
    path=(
        'jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh'
        '/security/products/vulnerabilities/js/vulinfo_search.js'
    ),
    condition_fn=lambda line: (
        'https://vuls.ricoh.com/ja/vulinfolist.json' in line
        and 'fileName' in line
        and 'dateParam' in line
    ),
    new_code=(
        '    let fileName;\n'
        '    if (document.location.hostname == "127.0.0.1"\n'
        '        || document.location.hostname == "stg-prv-wrc.scms.jp.ricoh.com"\n'
        '        || document.location.hostname == "stg-prv-jrc.scms.jp.ricoh.com") {\n'
        '        fileName = "http://127.0.0.1:5500/vuls.ricoh.com/ja/vulinfolist.json?" + dateParam;\n'
        '    } else {\n'
        '        fileName = "https://vuls.ricoh.com/ja/vulinfolist.json?" + dateParam;\n'
        '    }'
    )
)

# -----------------------------------------------
# generate .vscode/settings.json
# -----------------------------------------------

os.makedirs('.vscode', exist_ok=True)
settings = """{
    "liveServer.settings.root": "/jp.ricoh.com",
    "files.autoGuessEncoding": true
}
"""
with open('.vscode/settings.json', 'w', encoding='utf-8') as f:
    f.write(settings)
print('OK: .vscode/settings.json')
