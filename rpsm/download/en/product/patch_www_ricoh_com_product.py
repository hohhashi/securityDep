import os
import shutil

BASE = os.path.dirname(os.path.abspath(__file__))
os.chdir(BASE)

FILES = [
    (
        'product.patch.html',
        'www.ricoh.com/products/security/vulnerabilities/product.html'
    ),
    (
        'product_vul.patch.js',
        'www.ricoh.com/-/Media/Ricoh/Sites/com'
        '/products/security/vulnerabilities/js/product_vul.js'
    ),
    (
        'template.patch.js',
        'www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/template.js'
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
src_tb = os.path.join(BASE, 'www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase')
dst_tb = os.path.join(BASE, 'www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase.js')
if os.path.exists(src_tb):
    shutil.copy2(src_tb, dst_tb)
    print('OK: templateBase  ->  templateBase.js')
else:
    print('ERROR: templateBase not found (run download bat first)')

vscode_dir = os.path.join(BASE, '.vscode')
os.makedirs(vscode_dir, exist_ok=True)
settings_path = os.path.join(vscode_dir, 'settings.json')
settings = """{
    "liveServer.settings.root": "/www.ricoh.com",
    "files.autoGuessEncoding": true
}
"""
with open(settings_path, 'w', encoding='utf-8') as f:
    f.write(settings)
print('OK: .vscode/settings.json')
print()
print('done')
