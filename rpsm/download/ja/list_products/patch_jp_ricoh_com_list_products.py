import os
import shutil

BASE = os.path.dirname(os.path.abspath(__file__))
os.chdir(BASE)

FILES = [
    (
        'list_products.patch.html',
        'jp.ricoh.com/security/products/vulnerabilities/list_products.html'
    ),
    (
        'list_products.patch.js',
        'jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh'
        '/security/products/vulnerabilities/js/list_products.js'
    ),
    (
        'template.patch.js',
        'jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/template.js'
    ),
]

for src_name, dst_path in FILES:
    src = os.path.join(BASE, src_name)
    dst = os.path.join(BASE, dst_path)

    if not os.path.exists(src):
        print(f'ERROR: source not found: {src_name}')
        continue

    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)
    print(f'OK: {src_name}  ->  {dst_path}')

# templateBase -> templateBase.js
src_tb = os.path.join(BASE, 'jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase')
dst_tb = os.path.join(BASE, 'jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase.js')
if os.path.exists(src_tb):
    shutil.copy2(src_tb, dst_tb)
    print('OK: templateBase  ->  templateBase.js')
else:
    print('ERROR: templateBase not found (run download bat first)')

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
