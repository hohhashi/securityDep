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
    had_crlf = '\r\n' in text
    text = text.replace('\r\n', '\n')
    return text, encoding, had_crlf

def write_file(path, content, encoding, had_crlf):
    if had_crlf:
        content = content.replace('\n', '\r\n')
    with open(path, 'w', encoding=encoding, newline='') as f:
        f.write(content)

# -----------------------------------------------
# patch vul.js
#
# 変更内容:
#   1. data.item の初期値を空文字から空オブジェクトに変更
#      (Vue の初期レンダリング時の TypeError を防ぐ)
#   2. axios.get 一本から isLocal 分岐に変更
#      - isLocal 時: File System Access API + IndexedDB でローカル JSON を読む
#      - 非 isLocal 時: 従来の axios.get
#   3. データ加工を Vue への代入前にまとめて行う
#      (reactivity の問題を避けるため)
#   4. isLocal 時に product.id 内の adv リンクを書き換え
#      - href 属性: localizeVulUrl() でローカルパスへ変換
#      - リンクテキスト: document.location.origin + localizeVulUrl() で現ホストURLへ変換
# -----------------------------------------------

VUL_JS_PATH = (
    'jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh'
    '/security/products/vulnerabilities/js/vul.js'
)

# -----------------------------------------------
# patch 1: data.item の初期値
# -----------------------------------------------

ITEM_OLD = '    item: "",\n    isError:false'

ITEM_NEW = (
    '    item: {\n'
    '      importance: "",\n'
    '      version: "",\n'
    '      jvn: [],\n'
    '      severity: "",\n'
    '      status: "",\n'
    '      businessFields: [],\n'
    '      list1Title: "",\n'
    '      products: [],\n'
    '      list2Title: "",\n'
    '      thanks: "",\n'
    '      history: [],\n'
    '      url: "",\n'
    '      authenticityGuarantee: ""\n'
    '    },\n'
    '    isError:false'
)

# -----------------------------------------------
# patch 2: fileName/axios ブロックを isLocal 分岐 + 全処理まとめ版に置換
#
# 元コード（パッチ前）:
#   let fileName = "https://vuls.ricoh.com/..." + gID + ".json?" + dateParam;
#   //データロード
#   axios
#   .get(fileName)
#   .then(function(response) {
#     self.item = response.data;
#     ...加工...
#   })
#
# 新コード（パッチ後）:
#   let fileName;
#   let isLocal = (...);
#   fileName = "https://vuls.ricoh.com/..." + gID + ".json?" + dateParam;
#   function localizeVulUrl(...) { ... }
#   //データロード
#   var VULINFO_IDB_NAME = ...;
#   ...IndexedDB + File System Access API の関数群...
#   (isLocal ? loadVulDataViaFolderHandle() : axios.get(fileName))
#   .then(function(response) {
#     var d = response.data;
#     ...加工（Vue への代入前にまとめて）...
#     self.item = d;
#   })
# -----------------------------------------------

# 元の fileName〜.then(function(response){ ブロックにマッチする正規表現
# substr の空白バリエーション等に対応
OLD_BLOCK_PATTERN = re.compile(
    r'[ \t]*let fileName = "https://vuls\.ricoh\.com/ja/vulinfo/"'
    r'\s*\+\s*gID\.substr\(\s*6\s*,\s*4\s*\)\s*\+\s*"/"\s*\+\s*gID\s*\+\s*"\.json\?"\s*\+\s*dateParam;\n'
    r'(?:[ \t]*//.*\n)*'
    r'[ \t]*//データロード\n'
    r'[ \t]*axios\n'
    r'[ \t]*\.get\(fileName\)\n'
    r'[ \t]*\.then\(function\(response\)\s*\{\n'
    r'[ \t]*self\.item = response\.data;\n'
    r'[ \t]*//表示用データ作成\n'
    r'[ \t]*//最終更新日\n'
    r'[ \t]*tempLastUpdate = self\.item\["updatedAt"\];\n'
    r'[ \t]*let tempLastUpdateTS = Date\.parse\(tempLastUpdate\);\n'
    r'[ \t]*let tempLastUpdateDT = new Date\(tempLastUpdateTS\);\n'
    r'[ \t]*self\.item\["lastUpdate"\] = dayjs\(tempLastUpdateDT\)\.format\(\'YYYY年MM月DD日 H時mm分\'\);\n'
    r'[ \t]*//発行日\n'
    r'[ \t]*tempFirstEdition = self\.item\["publishedAt"\];\n'
    r'[ \t]*let tempFirstEditionTS = Date\.parse\(tempFirstEdition\);\n'
    r'[ \t]*let tempFirstEditionDT = new Date\(tempFirstEditionTS\);\n'
    r'[ \t]*self\.item\["firstEdition"\] = dayjs\(tempFirstEditionDT\)\.format\(\'YYYY年MM月DD日 H時mm分\'\);\n'
    r'[ \t]*//',
    re.MULTILINE
)

NEW_BLOCK = (
    '      let fileName;\n'
    '      let isLocal = (document.location.hostname == "127.0.0.1"\n'
    '          || document.location.hostname == "stg-prv-jrc.scms.jp.ricoh.com"\n'
    '          || document.location.hostname == "stg-prv-wrc.scms.jp.ricoh.com");\n'
    '      fileName = "https://vuls.ricoh.com/ja/vulinfo/" + gID.substr(6, 4) + "/" + gID + ".json?" + dateParam;\n'
    '      function localizeVulUrl(url) {\n'
    '        if (!isLocal) return url;\n'
    '        return url\n'
    '          .replace(/^https?:\\/\\/[^\\/]+/, "")\n'
    '          .replace(/\\/vul(\\?|$)/, "/vul.html$1")\n'
    '          .replace(/\\/adv(\\?|$)/, "/adv.html$1")\n'
    '          .replace(/\\/product(\\?|$)/, "/product.html$1")\n'
    '          .replace(/\\/list_products(\\?|$)/, "/list_products.html$1");\n'
    '      }\n'
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
    '      .then(function(response) {\n'
    '        var d = response.data;\n'
    '        //表示用データ作成\n'
    '        //最終更新日\n'
    '        var tempLastUpdate = d["updatedAt"];\n'
    '        var tempLastUpdateDT = new Date(Date.parse(tempLastUpdate));\n'
    '        d["lastUpdate"] = dayjs(tempLastUpdateDT).format(\'YYYY年MM月DD日 H時mm分\');\n'
    '        //発行日\n'
    '        var tempFirstEdition = d["publishedAt"];\n'
    '        var tempFirstEditionDT = new Date(Date.parse(tempFirstEdition));\n'
    '        d["firstEdition"] = dayjs(tempFirstEditionDT).format(\'YYYY年MM月DD日 H時mm分\');\n'
    '        //'
)

# -----------------------------------------------
# patch 3: .then の中身（businessFields 〜 self.item = d）
#
# 元コード:
#   //
#   self.item["businessFields"] = self.item.productStatus.businessFields;
#   for(let i=0; ...) { ... }
#   self.item["products"] = self.item.productStatus.products;
#   for(i=0; i<self.item.history.length; i++){
#     self.item.history[i]["date"] = self.item.history[i]["updatedAt"];
#   }
#
# 新コード:
#   //
#   d["businessFields"] = d.productStatus.businessFields;
#   for(var i=0; ...) { ... }
#   d["products"] = d.productStatus.products;
#   if(isLocal){ ... adv リンク書き換え ... }
#   for(var hi=0; hi<d.history.length; hi++){
#     d.history[hi]["date"] = d.history[hi]["updatedAt"];
#   }
#   self.item = d;
# -----------------------------------------------

THEN_OLD = (
    '        //\n'
    '        self.item["businessFields"] = self.item.productStatus.businessFields;\n'
    '        for(let i=0; i<self.item["businessFields"].length; i++){\n'
    '          self.item["businessFields"][i]["count"]=0;\n'
    '          let categories = self.item["businessFields"][i]["categories"];\n'
    '          for(let s=0; s<categories.length; s++){\n'
    '            self.item["businessFields"][i]["categories"][s]["count"]=0;\n'
    '            let subcategories = categories[s]["subCategories"];\n'
    '            for(let l=0; l<subcategories.length; l++){\n'
    '              self.item["businessFields"][i]["count"]++;\n'
    '              self.item["businessFields"][i]["categories"][s]["count"]++;\n'
    '            }\n'
    '          }\n'
    '        }\n'
    '        self.item["products"] = self.item.productStatus.products;\n'
    '        for(i=0; i<self.item.history.length; i++){\n'
    '          self.item.history[i]["date"] = self.item.history[i]["updatedAt"];//最終更新日\n'
    '        }\n'
    '      })'
)

THEN_NEW = (
    '        //\n'
    '        d["businessFields"] = d.productStatus.businessFields;\n'
    '        for(var i=0; i<d["businessFields"].length; i++){\n'
    '          d["businessFields"][i]["count"]=0;\n'
    '          var categories = d["businessFields"][i]["categories"];\n'
    '          for(var s=0; s<categories.length; s++){\n'
    '            d["businessFields"][i]["categories"][s]["count"]=0;\n'
    '            var subcategories = categories[s]["subCategories"];\n'
    '            for(var l=0; l<subcategories.length; l++){\n'
    '              d["businessFields"][i]["count"]++;\n'
    '              d["businessFields"][i]["categories"][s]["count"]++;\n'
    '            }\n'
    '          }\n'
    '        }\n'
    '        d["products"] = d.productStatus.products;\n'
    '        if(isLocal){\n'
    '          for(var pi=0; pi<d["products"].length; pi++){\n'
    '            var prod = d["products"][pi];\n'
    '            if(typeof prod.id === "string"){\n'
    '              // href 属性を書き換え（シングルクォート）\n'
    '              prod.id = prod.id.replace(/href=\'([^\']*)\'/g,\n'
    "                function(m, url){ return \"href='\" + localizeVulUrl(url) + \"'\"; }\n"
    '              );\n'
    '              // href 属性を書き換え（ダブルクォート）\n'
    '              prod.id = prod.id.replace(/href="([^"]*)"/g,\n'
    '                function(m, url){ return \'href="\' + localizeVulUrl(url) + \'"\'; }\n'
    '              );\n'
    '              // リンクテキスト（>URL</a> の部分）を現在のホストのURLに書き換え\n'
    '              prod.id = prod.id.replace(/>https?:\\/\\/[^<]*<\\/a>/g,\n'
    '                function(m){\n'
    '                  var text = m.slice(1, -4);\n'
    '                  return \'>\' + document.location.origin + localizeVulUrl(text) + \'</a>\';\n'
    '                }\n'
    '              );\n'
    '            }\n'
    '          }\n'
    '        }\n'
    '        for(var hi=0; hi<d.history.length; hi++){\n'
    '          d.history[hi]["date"] = d.history[hi]["updatedAt"];//最終更新日\n'
    '        }\n'
    '        // 全処理が終わってから Vue に渡す → reactivity が一度だけ発火\n'
    '        self.item = d;\n'
    '      })'
)

# -----------------------------------------------
# patch template.js
# -----------------------------------------------

TEMPLATE_JS_PATH = (
    'jp.ricoh.com/-/Media/Ricoh/Common'
    '/cmn_g_header_footer/js/template.js'
)

# -----------------------------------------------
# 実行
# -----------------------------------------------

def patch_item_init(path):
    if not os.path.exists(path):
        print(f'NOT FOUND: {path}')
        return False
    content, encoding, had_crlf = read_file(path)
    if ITEM_OLD not in content:
        print(f'SKIP item init: {path} (already patched or not found)')
        return True
    new_content = content.replace(ITEM_OLD, ITEM_NEW, 1)
    write_file(path, new_content, encoding, had_crlf)
    print(f'OK item init: {path}')
    return True

def patch_main_block(path):
    if not os.path.exists(path):
        print(f'NOT FOUND: {path}')
        return False
    content, encoding, had_crlf = read_file(path)
    new_content, count = OLD_BLOCK_PATTERN.subn(NEW_BLOCK, content, count=1)
    if count == 0:
        print(f'SKIP main block: {path} (already patched or pattern not found)')
    else:
        write_file(path, new_content, encoding, had_crlf)
        print(f'OK main block: {path}')
    return True

def patch_then_block(path):
    if not os.path.exists(path):
        print(f'NOT FOUND: {path}')
        return False
    content, encoding, had_crlf = read_file(path)
    if THEN_OLD not in content:
        print(f'SKIP then block: {path} (already patched or not found)')
        return True
    new_content = content.replace(THEN_OLD, THEN_NEW, 1)
    write_file(path, new_content, encoding, had_crlf)
    print(f'OK then block: {path}')
    return True

def patch_template_js(path):
    if not os.path.exists(path):
        print(f'NOT FOUND: {path}')
        return
    content, encoding, had_crlf = read_file(path)
    replaced = False
    new_lines = []
    for line in content.split('\n'):
        if 'templateBase' in line and 'template.src' in line:
            new_lines.append(
                'var template = document.createElement("script");\n'
                'template.src = "/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase.js";'
            )
            replaced = True
        else:
            new_lines.append(line)
    if replaced:
        write_file(path, '\n'.join(new_lines), encoding, had_crlf)
        print(f'OK: {path}')
    else:
        print(f'SKIP: {path} (target line not found)')

# vul.js の3ステップパッチ
patch_item_init(VUL_JS_PATH)
patch_main_block(VUL_JS_PATH)
patch_then_block(VUL_JS_PATH)

# template.js パッチ
patch_template_js(TEMPLATE_JS_PATH)

# .vscode/settings.json
os.makedirs('.vscode', exist_ok=True)
settings = """{
    "liveServer.settings.root": "/jp.ricoh.com",
    "files.autoGuessEncoding": true
}
"""
with open('.vscode/settings.json', 'w', encoding='utf-8') as f:
    f.write(settings)
print('OK: .vscode/settings.json')
