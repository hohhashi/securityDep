import os
import shutil

# このスクリプトのあるフォルダを基点にする
BASE = os.path.dirname(os.path.abspath(__file__))
os.chdir(BASE)

# -----------------------------------------------
# コピー先の定義
# -----------------------------------------------

FILES = [
    (
        'vul.js',
        'jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh'
        '/security/products/vulnerabilities/js/vul.js'
    ),
    (
        'vul.html',
        'jp.ricoh.com/security/products/vulnerabilities/vul.html'
    ),
]

# -----------------------------------------------
# コピー実行
# -----------------------------------------------

for src_name, dst_path in FILES:
    src = os.path.join(BASE, src_name)
    dst = os.path.join(BASE, dst_path)

    if not os.path.exists(src):
        print(f'ERROR: source not found: {src_name}')
        continue

    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)
    print(f'OK: {src_name}  ->  {dst_path}')

# -----------------------------------------------
# .vscode/settings.json
# -----------------------------------------------

vscode_dir = os.path.join(BASE, '.vscode')
os.makedirs(vscode_dir, exist_ok=True)
settings_path = os.path.join(vscode_dir, 'settings.json')
settings = """{
    "liveServer.settings.root": "/jp.ricoh.com",
    "files.autoGuessEncoding": true
}
"""
with open(settings_path, 'w', encoding='utf-8') as f:
    f.write(settings)
print('OK: .vscode/settings.json')

print()
print('done')
