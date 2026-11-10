"""
patch_www_ricoh_com_vulnerabilities.py

Applies patches to downloaded www.ricoh.com files for local preview:
  1. Copies the patched en/vulinfo_search.js (supports File System Access API
     and local folder selection) into the downloaded location.
  2. Creates .vscode/settings.json so Live Server uses www.ricoh.com as root.

Usage:
  Run this script from the same folder that contains www.ricoh.com/
  (i.e. the same folder as setup_www_ricoh_com_vulnerabilities.bat).

  py patch_www_ricoh_com_vulnerabilities.py
"""

import os
import sys
import shutil
import json

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

HERE = os.path.dirname(os.path.abspath(__file__))

# Source: patched vulinfo_search.js bundled next to this script
PATCHED_JS_SRC = os.path.join(HERE, "vulinfo_search.js")

# Destination: where download bat puts the original file
JS_DST = os.path.join(
    HERE,
    "www.ricoh.com",
    "-",
    "Media",
    "Ricoh",
    "Sites",
    "com",
    "products",
    "security",
    "vulnerabilities",
    "js",
    "vulinfo_search.js",
)

# .vscode/settings.json
VSCODE_DIR = os.path.join(HERE, ".vscode")
VSCODE_SETTINGS = os.path.join(VSCODE_DIR, "settings.json")

LIVE_SERVER_ROOT = "/www.ricoh.com"

# ---------------------------------------------------------------------------
# Step 1: copy patched vulinfo_search.js
# ---------------------------------------------------------------------------

def patch_vulinfo_search_js():
    if not os.path.isfile(PATCHED_JS_SRC):
        print("ERROR: vulinfo_search.js not found next to this script.")
        print("       Expected: " + PATCHED_JS_SRC)
        sys.exit(1)

    dst_dir = os.path.dirname(JS_DST)
    if not os.path.isdir(dst_dir):
        print("ERROR: destination directory not found.")
        print("       Expected: " + dst_dir)
        print("       Please run download_www_ricoh_com_vulnerabilities.bat first.")
        sys.exit(1)

    shutil.copy2(PATCHED_JS_SRC, JS_DST)
    print("OK  Copied vulinfo_search.js -> " + JS_DST)

# ---------------------------------------------------------------------------
# Step 2: create / update .vscode/settings.json
# ---------------------------------------------------------------------------

def setup_vscode_settings():
    settings = {}
    if os.path.isfile(VSCODE_SETTINGS):
        try:
            with open(VSCODE_SETTINGS, "r", encoding="utf-8") as f:
                settings = json.load(f)
        except Exception:
            settings = {}

    settings["liveServer.settings.root"] = LIVE_SERVER_ROOT

    os.makedirs(VSCODE_DIR, exist_ok=True)
    with open(VSCODE_SETTINGS, "w", encoding="utf-8") as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print("OK  " + VSCODE_SETTINGS)
    print("    liveServer.settings.root = " + LIVE_SERVER_ROOT)

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("=== patch_www_ricoh_com_vulnerabilities ===")
    patch_vulinfo_search_js()
    setup_vscode_settings()
    print("")
    print("Done. Open www.ricoh.com with Live Server to preview.")
