import os
import re
import sys

# move to the directory where this script is located
os.chdir(os.path.dirname(os.path.abspath(__file__)))

# -----------------------------------------------
# common
# -----------------------------------------------

def read_file(path):
    with open(path, 'rb') as f:
        raw = f.read()
    try:
        text = raw.decode('utf-8')
        encoding = 'utf-8'
    except UnicodeDecodeError:
        text = raw.decode('shift-jis')
        encoding = 'shift-jis'
    # normalize line endings to \n while reading; we restore \r\n on write
    had_crlf = '\r\n' in text
    text = text.replace('\r\n', '\n')
    return text, encoding, had_crlf

def write_file(path, content, encoding, had_crlf):
    if had_crlf:
        content = content.replace('\n', '\r\n')
    with open(path, 'w', encoding=encoding, newline='') as f:
        f.write(content)

def patch_block_regex(path, pattern, new_block):
    """Replace a regex-matched multi-line block with new_block.
    Tolerant of whitespace variations (e.g. substr(6, 4) vs substr( 6, 4 ))."""
    if not os.path.exists(path):
        print(f'NOT FOUND: {path}')
        return
    content, encoding, had_crlf = read_file(path)
    new_content, count = re.subn(pattern, new_block, content, count=1)
    if count == 0:
        print(f'SKIP: {path} (target block not found)')
        return
    write_file(path, new_content, encoding, had_crlf)
    print(f'OK: {path}')

def patch_file(path, condition_fn, new_code):
    """Legacy line-based patch (kept for template.js)."""
    if not os.path.exists(path):
        print(f'NOT FOUND: {path}')
        return
    content, encoding, had_crlf = read_file(path)
    lines = content.split('\n')
    replaced = False
    new_lines = []
    for line in lines:
        if condition_fn(line):
            new_lines.append(new_code)
            replaced = True
        else:
            new_lines.append(line)
    if replaced:
        write_file(path, '\n'.join(new_lines), encoding, had_crlf)
        print(f'OK: {path}')
    else:
        print(f'SKIP: {path} (target line not found)')

# --------------------------------------------
# patch vul.js: replace fileName resolution + axios call in one go
# --------------------------------------------

VUL_JS_PATH = (
    'jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh'
    '/security/products/vulnerabilities/js/vul.js'
)

# Matches the original fileName/axios block regardless of spacing
# variations inside substr(...) calls, e.g. substr(6, 4) or substr( 6, 4 ).
OLD_BLOCK_PATTERN = re.compile(
    r'[ \t]*let fileName = "https://vuls\.ricoh\.com/ja/vulinfo/"\s*\+\s*'
    r'gID\.substr\(\s*6\s*,\s*4\s*\)\s*\+\s*"/"\s*\+\s*gID\s*\+\s*"\.json\?"\s*\+\s*dateParam;\n'
    r'(?:[ \t]*//.*\n)*'
    r'[ \t]*//データロード\n'
    r'[ \t]*axios\n'
    r'[ \t]*\.get\(fileName\)\n'
    r'[ \t]*\.then\(function\(response\)\s*\{'
)

NEW_BLOCK = (
    '      let fileName;\n'
    '      let isLocal = (document.location.hostname == "127.0.0.1"\n'
    '          || document.location.hostname == "stg-prv-jrc.scms.jp.ricoh.com"\n'
    '          || document.location.hostname == "stg-prv-wrc.scms.jp.ricoh.com");\n'
    '      fileName = "https://vuls.ricoh.com/ja/vulinfo/" + gID.substr(6, 4) + "/" + gID + ".json?" + dateParam;\n'
    '      //データロード\n'
    '      var VULINFO_IDB_NAME = "vulinfoFolderHandleDB";\n'
    '      var VULINFO_IDB_STORE = "handles";\n'
    '      var VULINFO_IDB_KEY = "vulsRicohRoot";\n'
    '      function openVulinfoHandleDB() {\n'
    '        return new Promise(function (resolve, reject) {\n'
    '          var req = indexedDB.open(VULINFO_IDB_NAME, 1);\n'
    '          req.onupgradeneeded = function () {\n'
    '            req.result.createObjectStore(VULINFO_IDB_STORE);\n'
    '          };\n'
    '          req.onsuccess = function () { resolve(req.result); };\n'
    '          req.onerror = function () { reject(req.error); };\n'
    '        });\n'
    '      }\n'
    '      function saveVulinfoRootHandle(handle) {\n'
    '        return openVulinfoHandleDB().then(function (db) {\n'
    '          return new Promise(function (resolve, reject) {\n'
    '            var tx = db.transaction(VULINFO_IDB_STORE, "readwrite");\n'
    '            tx.objectStore(VULINFO_IDB_STORE).put(handle, VULINFO_IDB_KEY);\n'
    '            tx.oncomplete = function () { resolve(); };\n'
    '            tx.onerror = function () { reject(tx.error); };\n'
    '          });\n'
    '        });\n'
    '      }\n'
    '      function loadSavedVulinfoRootHandle() {\n'
    '        return openVulinfoHandleDB().then(function (db) {\n'
    '          return new Promise(function (resolve, reject) {\n'
    '            var tx = db.transaction(VULINFO_IDB_STORE, "readonly");\n'
    '            var req = tx.objectStore(VULINFO_IDB_STORE).get(VULINFO_IDB_KEY);\n'
    '            req.onsuccess = function () { resolve(req.result || null); };\n'
    '            req.onerror = function () { reject(req.error); };\n'
    '          });\n'
    '        });\n'
    '      }\n'
    '      function waitForUserClickToSelectFolder(message) {\n'
    '        return new Promise(function (resolve, reject) {\n'
    '          var btn = document.createElement("button");\n'
    '          btn.textContent = message;\n'
    '          btn.style.position = "fixed";\n'
    '          btn.style.top = "10px";\n'
    '          btn.style.left = "10px";\n'
    '          btn.style.zIndex = "9999";\n'
    '          btn.style.padding = "10px 16px";\n'
    '          btn.style.fontSize = "14px";\n'
    '          btn.onclick = function () {\n'
    '            btn.remove();\n'
    '            resolve();\n'
    '          };\n'
    '          document.body.appendChild(btn);\n'
    '        });\n'
    '      }\n'
    '      function pickAndSaveFolder() {\n'
    '        return waitForUserClickToSelectFolder("ローカルのvuls.ricoh.comフォルダを選択")\n'
    '          .then(function () {\n'
    '            return window.showDirectoryPicker({ id: "vulsRicohRoot", mode: "read" });\n'
    '          })\n'
    '          .then(function (handle) {\n'
    '            window.__vulsRicohRootHandle = handle;\n'
    '            return saveVulinfoRootHandle(handle).then(function () { return handle; });\n'
    '          });\n'
    '      }\n'
    '      function getVulsRicohRootHandle() {\n'
    '        if (window.__vulsRicohRootHandle) {\n'
    '          return Promise.resolve(window.__vulsRicohRootHandle);\n'
    '        }\n'
    '        if (!window.showDirectoryPicker) {\n'
    '          return Promise.reject(new Error("File System Access API is not supported in this browser"));\n'
    '        }\n'
    '        return loadSavedVulinfoRootHandle()\n'
    '          .catch(function () { return null; })\n'
    '          .then(function (savedHandle) {\n'
    '            if (!savedHandle) {\n'
    '              return pickAndSaveFolder();\n'
    '            }\n'
    '            return savedHandle.queryPermission({ mode: "read" })\n'
    '              .then(function (status) {\n'
    '                if (status === "granted") {\n'
    '                  window.__vulsRicohRootHandle = savedHandle;\n'
    '                  return savedHandle;\n'
    '                }\n'
    '                return waitForUserClickToSelectFolder("vuls.ricoh.comフォルダへのアクセスを許可")\n'
    '                  .then(function () {\n'
    '                    return savedHandle.requestPermission({ mode: "read" });\n'
    '                  })\n'
    '                  .then(function (result) {\n'
    '                    if (result === "granted") {\n'
    '                      window.__vulsRicohRootHandle = savedHandle;\n'
    '                      return savedHandle;\n'
    '                    }\n'
    '                    return pickAndSaveFolder();\n'
    '                  });\n'
    '              })\n'
    '              .catch(function () {\n'
    '                return pickAndSaveFolder();\n'
    '              });\n'
    '          });\n'
    '      }\n'
    '      function loadVulDataViaFolderHandle() {\n'
    '        var yearDir = gID.substr(6, 4);\n'
    '        var jsonName = gID + ".json";\n'
    '        return getVulsRicohRootHandle()\n'
    '          .then(function (rootHandle) {\n'
    '            return rootHandle.getDirectoryHandle("ja");\n'
    '          })\n'
    '          .then(function (jaHandle) {\n'
    '            return jaHandle.getDirectoryHandle("vulinfo");\n'
    '          })\n'
    '          .then(function (vulinfoHandle) {\n'
    '            return vulinfoHandle.getDirectoryHandle(yearDir);\n'
    '          })\n'
    '          .then(function (yearHandle) {\n'
    '            return yearHandle.getFileHandle(jsonName);\n'
    '          })\n'
    '          .then(function (fileHandle) {\n'
    '            return fileHandle.getFile();\n'
    '          })\n'
    '          .then(function (file) {\n'
    '            return file.text();\n'
    '          })\n'
    '          .then(function (text) {\n'
    '            return { data: JSON.parse(text) };\n'
    '          });\n'
    '      }\n'
    '      (isLocal ? loadVulDataViaFolderHandle() : axios.get(fileName))\n'
    '      .then(function(response) {'
)

patch_block_regex(VUL_JS_PATH, OLD_BLOCK_PATTERN, NEW_BLOCK)

# -----------------------------------------------
# patch template.js
# -----------------------------------------------

patch_file(
    path=(
        'jp.ricoh.com/-/Media/Ricoh/Common'
        '/cmn_g_header_footer/js/template.js'
    ),
    condition_fn=lambda line: (
        'templateBase' in line
        and 'template.src' in line
    ),
    new_code=(
        'var template = document.createElement("script");\n'
        'template.src = "/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase.js";'
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
