//! PDF レンダリング用の超小型ローカル HTTP サーバー。
//!
//! create / update 時に PDF 化が必要な HTML ページをブラウザから開けるように
//! 127.0.0.1 の任意ポートでサーブする。
//! ページ（detail.html）から `/vulinfo.json?lang=ja&id=ricoh-2026-000001` を
//! fetch すると、output_dir/{lang}/vulinfo/{YYYY}/{id}.json を読んで返す。

use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::thread::JoinHandle;
use std::time::Duration;

use tiny_http::{Header, Response, Server};

/// アセット（HTML / JS / CSS）はバイナリに埋め込む。
const DETAIL_HTML: &str = include_str!("../assets/detail.html");
const VUE_JS: &str    = include_str!("../assets/vue.global.prod.js");

pub struct PdfServer {
    pub base_url: String,
    stop_flag: Arc<AtomicBool>,
    handle: Option<JoinHandle<()>>,
}

impl PdfServer {
    /// `output_dir` 配下の JSON ファイルを配信するサーバーを起動する。
    pub fn start(output_dir: PathBuf) -> std::io::Result<Self> {
        let server = Server::http("127.0.0.1:0")
            .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e.to_string()))?;
        let addr = server.server_addr();
        let base_url = format!(
            "http://127.0.0.1:{}",
            addr.to_ip().unwrap().port()
        );

        let stop_flag = Arc::new(AtomicBool::new(false));
        let stop_flag_thread = stop_flag.clone();

        let handle = std::thread::spawn(move || loop {
            if stop_flag_thread.load(Ordering::SeqCst) {
                break;
            }
            match server.recv_timeout(Duration::from_millis(200)) {
                Ok(Some(req)) => handle_request(req, &output_dir),
                Ok(None) => continue,
                Err(_) => break,
            }
        });

        Ok(PdfServer {
            base_url,
            stop_flag,
            handle: Some(handle),
        })
    }

    /// PDF 化対象となる詳細ページの URL。
    /// lang は "ja" / "en"。
    pub fn detail_url(&self, lang: &str, id: &str) -> String {
        format!(
            "{}/detail.html?lang={}&id={}",
            self.base_url,
            lang,
            urlencode(id)
        )
    }

    /// サーバーを止めてスレッドの終了を待つ。
    pub fn stop(mut self) {
        self.stop_flag.store(true, Ordering::SeqCst);
        if let Some(h) = self.handle.take() {
            let _ = h.join();
        }
    }
}

impl Drop for PdfServer {
    fn drop(&mut self) {
        self.stop_flag.store(true, Ordering::SeqCst);
        if let Some(h) = self.handle.take() {
            let _ = h.join();
        }
    }
}

// ---- リクエストハンドラ ----

fn handle_request(request: tiny_http::Request, output_dir: &Path) {
    let url = request.url().to_string();
    let mut parts = url.splitn(2, '?');
    let path = parts.next().unwrap_or("/");
    let query = parts.next().unwrap_or("");

    let result = match path {
        "/detail.html" => respond_text(request, DETAIL_HTML, "text/html; charset=utf-8"),
        "/vue.global.prod.js" => {
            respond_text(request, VUE_JS, "application/javascript; charset=utf-8")
        }
        "/vulinfo.json" => respond_vulinfo_json(request, output_dir, query),
        _ => {
            let _ = request.respond(Response::from_string("Not Found").with_status_code(404));
            return;
        }
    };
    if let Err(e) = result {
        eprintln!("[pdf-server] レスポンス送信エラー: {}", e);
    }
}

/// `detail.html` が fetch する `/vulinfo.json?lang=ja&id=ricoh-2026-000001` を処理する。
/// output_dir/{lang}/vulinfo/{YYYY}/{id}.json を読んで返す。
fn respond_vulinfo_json(
    request: tiny_http::Request,
    output_dir: &Path,
    query: &str,
) -> std::io::Result<()> {
    let (lang, id) = parse_lang_id(query);
    let header = Header::from_bytes(&b"Content-Type"[..], &b"application/json; charset=utf-8"[..])
        .expect("invalid header");

    if lang.is_empty() || id.is_empty() {
        return request.respond(
            Response::from_string(r#"{"error":"missing lang or id"}"#)
                .with_header(header)
                .with_status_code(400),
        );
    }

    // id から年を取り出す（ricoh-YYYY-NNNNNN）
    let year = id.split('-').nth(1).unwrap_or("0000");
    let json_path = output_dir
        .join(&lang)
        .join("vulinfo")
        .join(year)
        .join(format!("{}.json", id));

    match std::fs::read_to_string(&json_path) {
        Ok(body) => request.respond(Response::from_string(body).with_header(header)),
        Err(_) => request.respond(
            Response::from_string("null")
                .with_header(header)
                .with_status_code(404),
        ),
    }
}

// ---- ユーティリティ ----

fn respond_text(
    request: tiny_http::Request,
    body: &str,
    content_type: &str,
) -> std::io::Result<()> {
    let header = Header::from_bytes(&b"Content-Type"[..], content_type.as_bytes())
        .expect("invalid header");
    request.respond(Response::from_string(body).with_header(header))
}

/// query 文字列（例: "lang=ja&id=ricoh-2026-000001"）から lang と id を取り出す。
fn parse_lang_id(query: &str) -> (String, String) {
    let mut lang = String::new();
    let mut id = String::new();
    for pair in query.split('&') {
        let mut kv = pair.splitn(2, '=');
        let key = kv.next().unwrap_or("");
        let val = urldecode(kv.next().unwrap_or(""));
        match key {
            "lang" => lang = val,
            "id" => id = val,
            _ => {}
        }
    }
    (lang, id)
}

fn urlencode(s: &str) -> String {
    let mut out = String::new();
    for b in s.bytes() {
        match b {
            b'A'..=b'Z' | b'a'..=b'z' | b'0'..=b'9' | b'-' | b'_' | b'.' | b'~' => {
                out.push(b as char)
            }
            _ => out.push_str(&format!("%{:02X}", b)),
        }
    }
    out
}

fn urldecode(s: &str) -> String {
    let bytes = s.as_bytes();
    let mut out = Vec::with_capacity(bytes.len());
    let mut i = 0;
    while i < bytes.len() {
        match bytes[i] {
            b'%' if i + 2 < bytes.len() => {
                if let Ok(hex) = std::str::from_utf8(&bytes[i + 1..i + 3]) {
                    if let Ok(byte) = u8::from_str_radix(hex, 16) {
                        out.push(byte);
                        i += 3;
                        continue;
                    }
                }
                out.push(bytes[i]);
                i += 1;
            }
            b'+' => {
                out.push(b' ');
                i += 1;
            }
            b => {
                out.push(b);
                i += 1;
            }
        }
    }
    String::from_utf8_lossy(&out).into_owned()
}
