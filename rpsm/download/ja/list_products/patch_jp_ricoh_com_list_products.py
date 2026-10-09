import os
import re

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
    Tolerant of whitespace variations."""
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

# --------------------------------------------
# patch list_products.js: replace fileName resolution + axios call
# with a File System Access API based local folder loader.
# Shares the same IndexedDB-persisted vuls.ricoh.com root handle
# used by other scripts (key: "vulsRicohRoot").
#
# Remote JSON path:
#   https://vuls.ricoh.com/ja/prodinfolist.json
# Local folder path (relative to vuls.ricoh.com root):
#   ja/prodinfolist.json
# --------------------------------------------

LIST_PRODUCTS_JS_PATH = (
    'jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh'
    '/security/products/vulnerabilities/js/list_products.js'
)

# Matches the original block:
#   let fileName = "https://vuls.ricoh.com/ja/prodinfolist.json?"+dateParam;
#   //let fileName = ...  (0 or more comment lines)
#   //データロード
#   axios
#   .get(fileName)
#   .then(function(response) {
OLD_BLOCK_PATTERN = re.compile(
    r'([ \t]*)let fileName = "https://vuls\.ricoh\.com/ja/prodinfolist\.json\?"\+dateParam;\n'
    r'(?:[ \t]*//.*\n)*'
    r'[ \t]*axios\n'
    r'[ \t]*\.get\(fileName\)\n'
    r'[ \t]*\.then\(function\(response\)\s*\{'
)

NEW_BLOCK = (
    r'\1let fileName = "https://vuls.ricoh.com/ja/prodinfolist.json?"+dateParam;\n'
    r'\1let isLocal = (document.location.hostname == "127.0.0.1"\n'
    r'\1    || document.location.hostname == "stg-prv-wrc.scms.jp.ricoh.com"\n'
    r'\1    || document.location.hostname == "stg-prv-jrc.scms.jp.ricoh.com");\n'
    r'\1//データロード\n'
    r'\1var LIST_PRODUCTS_IDB_NAME = "vulinfoFolderHandleDB";\n'
    r'\1var LIST_PRODUCTS_IDB_STORE = "handles";\n'
    r'\1var LIST_PRODUCTS_IDB_KEY = "vulsRicohRoot";\n'
    r'\1function openListProductsHandleDB() {\n'
    r'\1  return new Promise(function (resolve, reject) {\n'
    r'\1    var req = indexedDB.open(LIST_PRODUCTS_IDB_NAME, 1);\n'
    r'\1    req.onupgradeneeded = function () {\n'
    r'\1      req.result.createObjectStore(LIST_PRODUCTS_IDB_STORE);\n'
    r'\1    };\n'
    r'\1    req.onsuccess = function () { resolve(req.result); };\n'
    r'\1    req.onerror = function () { reject(req.error); };\n'
    r'\1  });\n'
    r'\1}\n'
    r'\1function saveListProductsRootHandle(handle) {\n'
    r'\1  return openListProductsHandleDB().then(function (db) {\n'
    r'\1    return new Promise(function (resolve, reject) {\n'
    r'\1      var tx = db.transaction(LIST_PRODUCTS_IDB_STORE, "readwrite");\n'
    r'\1      tx.objectStore(LIST_PRODUCTS_IDB_STORE).put(handle, LIST_PRODUCTS_IDB_KEY);\n'
    r'\1      tx.oncomplete = function () { resolve(); };\n'
    r'\1      tx.onerror = function () { reject(tx.error); };\n'
    r'\1    });\n'
    r'\1  });\n'
    r'\1}\n'
    r'\1function loadSavedListProductsRootHandle() {\n'
    r'\1  return openListProductsHandleDB().then(function (db) {\n'
    r'\1    return new Promise(function (resolve, reject) {\n'
    r'\1      var tx = db.transaction(LIST_PRODUCTS_IDB_STORE, "readonly");\n'
    r'\1      var req = tx.objectStore(LIST_PRODUCTS_IDB_STORE).get(LIST_PRODUCTS_IDB_KEY);\n'
    r'\1      req.onsuccess = function () { resolve(req.result || null); };\n'
    r'\1      req.onerror = function () { reject(req.error); };\n'
    r'\1    });\n'
    r'\1  });\n'
    r'\1}\n'
    r'\1function waitForUserClickToSelectFolderListProducts(message) {\n'
    r'\1  return new Promise(function (resolve, reject) {\n'
    r'\1    var btn = document.createElement("button");\n'
    r'\1    btn.textContent = message;\n'
    r'\1    btn.style.position = "fixed";\n'
    r'\1    btn.style.top = "10px";\n'
    r'\1    btn.style.left = "10px";\n'
    r'\1    btn.style.zIndex = "9999";\n'
    r'\1    btn.style.padding = "10px 16px";\n'
    r'\1    btn.style.fontSize = "14px";\n'
    r'\1    btn.onclick = function () {\n'
    r'\1      btn.remove();\n'
    r'\1      resolve();\n'
    r'\1    };\n'
    r'\1    document.body.appendChild(btn);\n'
    r'\1  });\n'
    r'\1}\n'
    r'\1function pickAndSaveFolderListProducts() {\n'
    r'\1  return waitForUserClickToSelectFolderListProducts("ローカルのvuls.ricoh.comフォルダを選択")\n'
    r'\1    .then(function () {\n'
    r'\1      return window.showDirectoryPicker({ id: "vulsRicohRoot", mode: "read" });\n'
    r'\1    })\n'
    r'\1    .then(function (handle) {\n'
    r'\1      window.__vulsRicohRootHandle = handle;\n'
    r'\1      return saveListProductsRootHandle(handle).then(function () { return handle; });\n'
    r'\1    });\n'
    r'\1}\n'
    r'\1function getVulsRicohRootHandleListProducts() {\n'
    r'\1  if (window.__vulsRicohRootHandle) {\n'
    r'\1    return Promise.resolve(window.__vulsRicohRootHandle);\n'
    r'\1  }\n'
    r'\1  if (!window.showDirectoryPicker) {\n'
    r'\1    return Promise.reject(new Error("File System Access API is not supported in this browser"));\n'
    r'\1  }\n'
    r'\1  return loadSavedListProductsRootHandle()\n'
    r'\1    .catch(function () { return null; })\n'
    r'\1    .then(function (savedHandle) {\n'
    r'\1      if (!savedHandle) {\n'
    r'\1        return pickAndSaveFolderListProducts();\n'
    r'\1      }\n'
    r'\1      return savedHandle.queryPermission({ mode: "read" })\n'
    r'\1        .then(function (status) {\n'
    r'\1          if (status === "granted") {\n'
    r'\1            window.__vulsRicohRootHandle = savedHandle;\n'
    r'\1            return savedHandle;\n'
    r'\1          }\n'
    r'\1          return waitForUserClickToSelectFolderListProducts("vuls.ricoh.comフォルダへのアクセスを許可")\n'
    r'\1            .then(function () {\n'
    r'\1              return savedHandle.requestPermission({ mode: "read" });\n'
    r'\1            })\n'
    r'\1            .then(function (result) {\n'
    r'\1              if (result === "granted") {\n'
    r'\1                window.__vulsRicohRootHandle = savedHandle;\n'
    r'\1                return savedHandle;\n'
    r'\1              }\n'
    r'\1              return pickAndSaveFolderListProducts();\n'
    r'\1            });\n'
    r'\1        })\n'
    r'\1        .catch(function () {\n'
    r'\1          return pickAndSaveFolderListProducts();\n'
    r'\1        });\n'
    r'\1    });\n'
    r'\1}\n'
    r'\1function loadListProductsDataViaFolderHandle() {\n'
    r'\1  return getVulsRicohRootHandleListProducts()\n'
    r'\1    .then(function (rootHandle) {\n'
    r'\1      return rootHandle.getDirectoryHandle("ja");\n'
    r'\1    })\n'
    r'\1    .then(function (jaHandle) {\n'
    r'\1      return jaHandle.getFileHandle("prodinfolist.json");\n'
    r'\1    })\n'
    r'\1    .then(function (fileHandle) {\n'
    r'\1      return fileHandle.getFile();\n'
    r'\1    })\n'
    r'\1    .then(function (file) {\n'
    r'\1      return file.text();\n'
    r'\1    })\n'
    r'\1    .then(function (text) {\n'
    r'\1      return { data: JSON.parse(text) };\n'
    r'\1    });\n'
    r'\1}\n'
    r'\1(isLocal ? loadListProductsDataViaFolderHandle() : axios.get(fileName))\n'
    r'\1  .then(function(response) {'
)

patch_block_regex(LIST_PRODUCTS_JS_PATH, OLD_BLOCK_PATTERN, NEW_BLOCK)

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
