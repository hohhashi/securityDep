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

def patch_block_regex(label, path, pattern, new_block, content):
    new_content, count = re.subn(pattern, new_block, content, count=1)
    if count == 0:
        print(f'SKIP {label}: target block not found')
        return content
    print(f'OK {label}')
    return new_content

# -----------------------------------------------
# target file
# -----------------------------------------------

VULINFO_SEARCH_JS_PATH = (
    'jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh'
    '/security/products/vulnerabilities/js/vulinfo_search.js'
)

if not os.path.exists(VULINFO_SEARCH_JS_PATH):
    print(f'NOT FOUND: {VULINFO_SEARCH_JS_PATH}')
    import sys; sys.exit(1)

content, encoding, had_crlf = read_file(VULINFO_SEARCH_JS_PATH)

# -----------------------------------------------
# Patch 1: replace axios call with FSA + isLocal + localizeVulUrl
# -----------------------------------------------

OLD_BLOCK_PATTERN = re.compile(
    r'([ \t]*)let fileName = "https://vuls\.ricoh\.com/ja/vulinfolist\.json\?"\s*\+\s*dateParam;\n'
    r'(?:[ \t]*//.*\n)*'
    r'[ \t]*axios\n'
    r'[ \t]*\.get\(fileName\)\n'
    r'[ \t]*\.then\(function\(response\)\s*\{'
)

NEW_BLOCK = (
    r'\1let fileName;\n'
    r'\1let isLocal = (document.location.hostname == "127.0.0.1"\n'
    r'\1    || document.location.hostname == "stg-prv-wrc.scms.jp.ricoh.com"\n'
    r'\1    || document.location.hostname == "stg-prv-jrc.scms.jp.ricoh.com");\n'
    r'\1fileName = "https://vuls.ricoh.com/ja/vulinfolist.json?" + dateParam;\n'
    r'\1function localizeVulUrl(url) {\n'
    r'\1  if (!isLocal) return url;\n'
    r'\1  return url\n'
    r'\1    .replace(/\/vul(\?|$)/, "/vul.html$1")\n'
    r'\1    .replace(/\/adv(\?|$)/, "/adv.html$1")\n'
    r'\1    .replace(/\/product(\?|$)/, "/product.html$1")\n'
    r'\1    .replace(/\/list_products(\?|$)/, "/list_products.html$1");\n'
    r'\1}\n'
    r'\1//データロード\n'
    r'\1var VULINFO_IDB_NAME = "vulinfoFolderHandleDB";\n'
    r'\1var VULINFO_IDB_STORE = "handles";\n'
    r'\1var VULINFO_IDB_KEY = "vulsRicohRoot";\n'
    r'\1function openVulinfoHandleDB() {\n'
    r'\1  return new Promise(function (resolve, reject) {\n'
    r'\1    var req = indexedDB.open(VULINFO_IDB_NAME, 1);\n'
    r'\1    req.onupgradeneeded = function () {\n'
    r'\1      req.result.createObjectStore(VULINFO_IDB_STORE);\n'
    r'\1    };\n'
    r'\1    req.onsuccess = function () { resolve(req.result); };\n'
    r'\1    req.onerror = function () { reject(req.error); };\n'
    r'\1  });\n'
    r'\1}\n'
    r'\1function saveVulinfoRootHandle(handle) {\n'
    r'\1  return openVulinfoHandleDB().then(function (db) {\n'
    r'\1    return new Promise(function (resolve, reject) {\n'
    r'\1      var tx = db.transaction(VULINFO_IDB_STORE, "readwrite");\n'
    r'\1      tx.objectStore(VULINFO_IDB_STORE).put(handle, VULINFO_IDB_KEY);\n'
    r'\1      tx.oncomplete = function () { resolve(); };\n'
    r'\1      tx.onerror = function () { reject(tx.error); };\n'
    r'\1    });\n'
    r'\1  });\n'
    r'\1}\n'
    r'\1function loadSavedVulinfoRootHandle() {\n'
    r'\1  return openVulinfoHandleDB().then(function (db) {\n'
    r'\1    return new Promise(function (resolve, reject) {\n'
    r'\1      var tx = db.transaction(VULINFO_IDB_STORE, "readonly");\n'
    r'\1      var req = tx.objectStore(VULINFO_IDB_STORE).get(VULINFO_IDB_KEY);\n'
    r'\1      req.onsuccess = function () { resolve(req.result || null); };\n'
    r'\1      req.onerror = function () { reject(req.error); };\n'
    r'\1    });\n'
    r'\1  });\n'
    r'\1}\n'
    r'\1function waitForUserClickToSelectFolder(message) {\n'
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
    r'\1function pickAndSaveFolder() {\n'
    r'\1  return waitForUserClickToSelectFolder("ローカルのvuls.ricoh.comフォルダを選択")\n'
    r'\1    .then(function () {\n'
    r'\1      return window.showDirectoryPicker({ id: "vulsRicohRoot", mode: "read" });\n'
    r'\1    })\n'
    r'\1    .then(function (handle) {\n'
    r'\1      window.__vulsRicohRootHandle = handle;\n'
    r'\1      return saveVulinfoRootHandle(handle).then(function () { return handle; });\n'
    r'\1    });\n'
    r'\1}\n'
    r'\1function getVulsRicohRootHandle() {\n'
    r'\1  if (window.__vulsRicohRootHandle) {\n'
    r'\1    return Promise.resolve(window.__vulsRicohRootHandle);\n'
    r'\1  }\n'
    r'\1  if (!window.showDirectoryPicker) {\n'
    r'\1    return Promise.reject(new Error("File System Access API is not supported in this browser"));\n'
    r'\1  }\n'
    r'\1  return loadSavedVulinfoRootHandle()\n'
    r'\1    .catch(function () { return null; })\n'
    r'\1    .then(function (savedHandle) {\n'
    r'\1      if (!savedHandle) {\n'
    r'\1        return pickAndSaveFolder();\n'
    r'\1      }\n'
    r'\1      return savedHandle.queryPermission({ mode: "read" })\n'
    r'\1        .then(function (status) {\n'
    r'\1          if (status === "granted") {\n'
    r'\1            window.__vulsRicohRootHandle = savedHandle;\n'
    r'\1            return savedHandle;\n'
    r'\1          }\n'
    r'\1          return waitForUserClickToSelectFolder("vuls.ricoh.comフォルダへのアクセスを許可")\n'
    r'\1            .then(function () {\n'
    r'\1              return savedHandle.requestPermission({ mode: "read" });\n'
    r'\1            })\n'
    r'\1            .then(function (result) {\n'
    r'\1              if (result === "granted") {\n'
    r'\1                window.__vulsRicohRootHandle = savedHandle;\n'
    r'\1                return savedHandle;\n'
    r'\1              }\n'
    r'\1              return pickAndSaveFolder();\n'
    r'\1            });\n'
    r'\1        })\n'
    r'\1        .catch(function () {\n'
    r'\1          return pickAndSaveFolder();\n'
    r'\1        });\n'
    r'\1    });\n'
    r'\1}\n'
    r'\1function loadVulListDataViaFolderHandle() {\n'
    r'\1  return getVulsRicohRootHandle()\n'
    r'\1    .then(function (rootHandle) {\n'
    r'\1      return rootHandle.getDirectoryHandle("ja");\n'
    r'\1    })\n'
    r'\1    .then(function (jaHandle) {\n'
    r'\1      return jaHandle.getFileHandle("vulinfolist.json");\n'
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
    r'\1(isLocal ? loadVulListDataViaFolderHandle() : axios.get(fileName))\n'
    r'\1  .then(function(response) {'
)

content = patch_block_regex('step1', VULINFO_SEARCH_JS_PATH, OLD_BLOCK_PATTERN, NEW_BLOCK, content)

# -----------------------------------------------
# Patch 2: linkUrl localization
# -----------------------------------------------

LINKURL_PATTERN = re.compile(
    r'([ \t]*)//リンクURL\n'
    r'[ \t]*self\.allItems\[i\]\["linkUrl"\] = "/security/products/vulnerabilities/vul\?id=" \+ self\.allItems\[i\]\.id;\n'
    r'(?:[ \t]*//self\.allItems\[i\]\["linkUrl"\].*\n)?'
)

LINKURL_NEW = (
    r'\1//リンクURL\n'
    r'\1self.allItems[i]["linkUrl"] = localizeVulUrl(\n'
    r'\1  "/security/products/vulnerabilities/vul?id=" + self.allItems[i].id\n'
    r'\1);\n'
    r'\1//self.allItems[i]["linkUrl"] = "vul?id=" + self.allItems[i].id;\n'
)

content = patch_block_regex('step2', VULINFO_SEARCH_JS_PATH, LINKURL_PATTERN, LINKURL_NEW, content)

write_file(VULINFO_SEARCH_JS_PATH, content, encoding, had_crlf)
print(f'Written: {VULINFO_SEARCH_JS_PATH}')

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
