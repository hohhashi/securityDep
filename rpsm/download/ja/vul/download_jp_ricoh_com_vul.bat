@echo off
rem HARから生成したcurlコマンド一覧
rem jp.ricoh.com - 2026/06/03
rem URLのパス構造をそのままフォルダとして再現します
rem 実行: download_ricoh.bat

set UA=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/148.0.0.0 Safari/537.36
set REF=https://jp.ricoh.com/

if not exist "jp.ricoh.com\security\products\vulnerabilities" mkdir "jp.ricoh.com\security\products\vulnerabilities"
curl -L -o "jp.ricoh.com\security\products\vulnerabilities\vul.html" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/security/products/vulnerabilities/vul?id=ricoh-2026-000004"

if not exist "jp.ricoh.com\-\Media\ScAssets\System\Lib" mkdir "jp.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\Lib\jquery.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/ScAssets/System/Lib/jquery.min.js?cacheDate=202605251414"

if not exist "jp.ricoh.com\-\Media\ScAssets\System\Lib" mkdir "jp.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\Lib\jquery.bxslider.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/ScAssets/System/Lib/jquery.bxslider.min.js?cacheDate=202605251414"

if not exist "jp.ricoh.com\-\Media\ScAssets\System\Lib\bxslider" mkdir "jp.ricoh.com\-\Media\ScAssets\System\Lib\bxslider"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\Lib\bxslider\jquery.bxslider.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/ScAssets/System/Lib/bxslider/jquery.bxslider.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\jquery-match-height.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/jquery-match-height.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\solution-product-template.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/solution-product-template.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\template.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/template.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\init.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/init.js"

if not exist "jp.ricoh.com\Scripts\dist\lib" mkdir "jp.ricoh.com\Scripts\dist\lib"
curl -L -o "jp.ricoh.com\Scripts\dist\lib\vendor.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/Scripts/dist/lib/vendor.js?cacheDate=202605251414"

if not exist "jp.ricoh.com\-\Media\ScAssets\System\JS" mkdir "jp.ricoh.com\-\Media\ScAssets\System\JS"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\JS\common.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/ScAssets/System/JS/common.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\import.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/import.css?cacheDate=202605251414"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\solution-product-template.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/solution-product-template.css?cacheDate=202605251414"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\globalnavi.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/globalnavi.js?cacheDate=202605251414"

if not exist "jp.ricoh.com\-\Media\ScAssets\System\Lib" mkdir "jp.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\Lib\jquery.tile.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/ScAssets/System/Lib/jquery.tile.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video\jquery.magnific-popup.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/modal-for-video/jquery.magnific-popup.min.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video\jquery.modal-for-video.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/modal-for-video/jquery.modal-for-video.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video\youtube_modal_setting.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/modal-for-video/youtube_modal_setting.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video\magnific-popup.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/modal-for-video/magnific-popup.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\css\template.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/css/template.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\common.vanilla.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/common.vanilla.js"

if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\consent\018f808b-1528-71b1-a5ff-393a4efd2723" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\consent\018f808b-1528-71b1-a5ff-393a4efd2723"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\consent\018f808b-1528-71b1-a5ff-393a4efd2723\OtAutoBlock.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/consent/018f808b-1528-71b1-a5ff-393a4efd2723/OtAutoBlock.js"

if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\otSDKStub.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/scripttemplates/otSDKStub.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v1\lib\uniform" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v1\lib\uniform"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v1\lib\uniform\jquery.uniform.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v1/lib/uniform/jquery.uniform.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\css\vul.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh/security/products/vulnerabilities/css/vul.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo\logo.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/logo/logo.svg"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\globe.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/globe.svg"

if not exist "jp.ricoh.com\www.ricoh.co.jp\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "jp.ricoh.com\www.ricoh.co.jp\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\www.ricoh.co.jp\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\blank-grey.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.co.jp/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/blank-grey.svg"

if not exist "jp.ricoh.com\-\media\Ricoh\Sites\jp_ricoh\products\img" mkdir "jp.ricoh.com\-\media\Ricoh\Sites\jp_ricoh\products\img"
curl -L -o "jp.ricoh.com\-\media\Ricoh\Sites\jp_ricoh\products\img\img_01.webp" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/media/Ricoh/Sites/jp_ricoh/products/img/img_01.webp?rev=8fa319fe325047019db019d2d41e6101&hash=7316D46F5C19FC31625CC26B919608F3"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\blank-grey.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/blank-grey.svg"

if not exist "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\img" mkdir "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\img"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\img\ic_important.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh/security/products/vulnerabilities/img/ic_important.svg"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\blank-white.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/blank-white.svg"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\youtube-icon.png" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/youtube-icon.png"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\facebook.png" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/facebook.png"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\x.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/x.svg"

if not exist "jp.ricoh.com\cdn.jsdelivr.net\npm\dayjs@1" mkdir "jp.ricoh.com\cdn.jsdelivr.net\npm\dayjs@1"
curl -L -o "jp.ricoh.com\cdn.jsdelivr.net\npm\dayjs@1\dayjs.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdn.jsdelivr.net/npm/dayjs@1/dayjs.min.js"

if not exist "jp.ricoh.com\cdnjs.cloudflare.com\ajax\libs\jquery-easing\1.4.1" mkdir "jp.ricoh.com\cdnjs.cloudflare.com\ajax\libs\jquery-easing\1.4.1"
curl -L -o "jp.ricoh.com\cdnjs.cloudflare.com\ajax\libs\jquery-easing\1.4.1\jquery.easing.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdnjs.cloudflare.com/ajax/libs/jquery-easing/1.4.1/jquery.easing.min.js"

if not exist "jp.ricoh.com\www.promisejs.org\polyfills" mkdir "jp.ricoh.com\www.promisejs.org\polyfills"
curl -L -o "jp.ricoh.com\www.promisejs.org\polyfills\promise-6.1.0.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.promisejs.org/polyfills/promise-6.1.0.min.js"

if not exist "jp.ricoh.com\cdn.jsdelivr.net\npm\axios\dist" mkdir "jp.ricoh.com\cdn.jsdelivr.net\npm\axios\dist"
curl -L -o "jp.ricoh.com\cdn.jsdelivr.net\npm\axios\dist\axios.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"

if not exist "jp.ricoh.com\cdn.jsdelivr.net\npm\vue\dist" mkdir "jp.ricoh.com\cdn.jsdelivr.net\npm\vue\dist"
curl -L -o "jp.ricoh.com\cdn.jsdelivr.net\npm\vue\dist\vue.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdn.jsdelivr.net/npm/vue/dist/vue.min.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\js\vul.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh/security/products/vulnerabilities/js/vul.js"

if not exist "jp.ricoh.com\ce.mf.marsflag.com\v2\js" mkdir "jp.ricoh.com\ce.mf.marsflag.com\v2\js"
curl -L -o "jp.ricoh.com\ce.mf.marsflag.com\v2\js\mf-search.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://ce.mf.marsflag.com/v2/js/mf-search.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\initBase.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/initBase.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\sc_reset.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/sc_reset.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\reset.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/reset.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\print.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/print.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\gl_header.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/gl_header.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\gl_footer.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/gl_footer.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\option.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/option.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\common.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/common.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\sc_common.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/sc_common.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cookie-management\css" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cookie-management\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cookie-management\css\common.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cookie-management/css/common.css"

if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\consent\018f808b-1528-71b1-a5ff-393a4efd2723" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\consent\018f808b-1528-71b1-a5ff-393a4efd2723"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\consent\018f808b-1528-71b1-a5ff-393a4efd2723\018f808b-1528-71b1-a5ff-393a4efd2723.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/consent/018f808b-1528-71b1-a5ff-393a4efd2723/018f808b-1528-71b1-a5ff-393a4efd2723.json"

if not exist "jp.ricoh.com\geolocation.onetrust.com\cookieconsentpub\v1\geo" mkdir "jp.ricoh.com\geolocation.onetrust.com\cookieconsentpub\v1\geo"
curl -L -o "jp.ricoh.com\geolocation.onetrust.com\cookieconsentpub\v1\geo\location.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://geolocation.onetrust.com/cookieconsentpub/v1/geo/location"

if not exist "jp.ricoh.com\vuls.ricoh.com\ja\vulinfo\2026" mkdir "jp.ricoh.com\vuls.ricoh.com\ja\vulinfo\2026"
curl -L -o "jp.ricoh.com\vuls.ricoh.com\ja\vulinfo\2026\ricoh-2026-000004.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://vuls.ricoh.com/ja/vulinfo/2026/ricoh-2026-000004.json?2026639"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\templateBase.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase"

if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0\otBannerSdk.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/scripttemplates/202506.1.0/otBannerSdk.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\search.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/search.svg"

if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\consent\018f808b-1528-71b1-a5ff-393a4efd2723\0190e459-e875-7991-9583-258a562cd3aa" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\consent\018f808b-1528-71b1-a5ff-393a4efd2723\0190e459-e875-7991-9583-258a562cd3aa"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\consent\018f808b-1528-71b1-a5ff-393a4efd2723\0190e459-e875-7991-9583-258a562cd3aa\ja.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/consent/018f808b-1528-71b1-a5ff-393a4efd2723/0190e459-e875-7991-9583-258a562cd3aa/ja.json"

if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0\assets" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0\assets"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0\assets\otFlat.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/scripttemplates/202506.1.0/assets/otFlat.json"

if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0\assets\v2" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0\assets\v2"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0\assets\v2\otPcCenter.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/scripttemplates/202506.1.0/assets/v2/otPcCenter.json"

if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0\assets" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0\assets"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202506.1.0\assets\otCommonStyles.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/scripttemplates/202506.1.0/assets/otCommonStyles.css"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg\blank-primary-color.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/svg/blank-primary-color.svg"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg\arrow-right-primary-color.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/svg/arrow-right-primary-color.svg"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\icon_anchor_top.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/icon_anchor_top.svg"

if not exist "jp.ricoh.com\www.youtube.com\" mkdir "jp.ricoh.com\www.youtube.com\"
curl -L -o "jp.ricoh.com\www.youtube.com\\iframe_api.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.youtube.com/iframe_api"

rem [SKIP-TRACKING] https://www.googletagmanager.com/gtm.js?id=GTM-KX9KHD
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtm.js?id=GTM-M3X5GT6
if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\static" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\static"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\static\ot_close.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/logos/static/ot_close.svg"

if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\static" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\static"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\static\ot_guard_logo.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/logos/static/ot_guard_logo.svg"

if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\b68d8172-566e-4cb6-8189-dc0031d2ae7a\018f80df-3071-7bd6-a392-ddd32a21517b\a0ec1df9-a5f5-4350-bb05-1e92c79947f1" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\b68d8172-566e-4cb6-8189-dc0031d2ae7a\018f80df-3071-7bd6-a392-ddd32a21517b\a0ec1df9-a5f5-4350-bb05-1e92c79947f1"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\b68d8172-566e-4cb6-8189-dc0031d2ae7a\018f80df-3071-7bd6-a392-ddd32a21517b\a0ec1df9-a5f5-4350-bb05-1e92c79947f1\Lockup_Logo_RGB_0.6x.png" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/logos/b68d8172-566e-4cb6-8189-dc0031d2ae7a/018f80df-3071-7bd6-a392-ddd32a21517b/a0ec1df9-a5f5-4350-bb05-1e92c79947f1/Lockup_Logo_RGB_0.6x.png"

if not exist "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\static" mkdir "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\static"
curl -L -o "jp.ricoh.com\cookie-cdn.cookiepro.com\logos\static\poweredBy_cp_logo.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/logos/static/poweredBy_cp_logo.svg"

if not exist "jp.ricoh.com\www.youtube.com\s\player\4f38b487\www-widgetapi.vflset" mkdir "jp.ricoh.com\www.youtube.com\s\player\4f38b487\www-widgetapi.vflset"
curl -L -o "jp.ricoh.com\www.youtube.com\s\player\4f38b487\www-widgetapi.vflset\www-widgetapi.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.youtube.com/s/player/4f38b487/www-widgetapi.vflset/www-widgetapi.js"

rem [SKIP-TRACKING] https://www.googletagmanager.com/gtm.js?id=GTM-NPMDKGK&gtm=4e6611
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtm.js?id=GTM-583J9QP&gtm=4e6611
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtm.js?id=GTM-PVQGW62&gtm=4e6611
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtm.js?id=GTM-5BF3GL2&gtm=4e6611
rem [SKIP-TRACKING] https://img03.en25.com/i/elqCfg.min.js
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtag/js?id=G-NQ01T89XSX&cx=c&gtm=4e6611
rem [SKIP-TRACKING] https://s1406731827.t.eloqua.com/visitor/v200/svrGP?pps=70&siteid=1406731827&ms=590
rem [SKIP-TRACKING] https://s1406731827.t.eloqua.com/visitor/v200/svrGP?pps=3&siteid=1406731827&ref=https%3A%2F%2Fjp.ric
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtag/js?id=G-1W7QW96RNV&cx=c&gtm=4e6611
rem [SKIP-POST] https://www.google-analytics.com/g/collect?v=2&tid=G-NQ01T89XSX&gtm=45je6611v876718451z8867447766za2
rem [SKIP-POST] https://www.google-analytics.com/g/collect?v=2&tid=G-NQ01T89XSX&gtm=45je6611v876718451z8867447766za2
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtag/destination?id=AW-823978455&cx=c&gtm=4e6611
rem [SKIP-POST] https://www.google-analytics.com/g/collect?v=2&tid=G-1W7QW96RNV&gtm=45je6611v883120914z8867447067za2
rem [SKIP-POST] https://www.google-analytics.com/g/collect?v=2&tid=G-1W7QW96RNV&gtm=45je6611v883120914z8867447067za2
rem [SKIP-TRACKING] https://googleads.g.doubleclick.net/pagead/viewthroughconversion/823978455/?random=1780477654981&cv=
rem [SKIP-POST] https://www.google.com/rmkt/collect/823978455/?random=1780477654981&cv=11&fst=1780477654981&fmt=8&bg
rem [SKIP-POST] https://www.google.com/ccm/collect?rcb=12&frm=0&ae=g&auid=1864796339.1780473230&dt=%E8%84%86%E5%BC%B
rem [SKIP-TRACKING] https://www.google.com/pagead/1p-user-list/823978455/?random=1780477654981&cv=11&fst=1780477200000&b
rem [SKIP-TRACKING] https://www.google.co.jp/pagead/1p-user-list/823978455/?random=1780477654981&cv=11&fst=1780477200000
if not exist "jp.ricoh.com\-\media\ScAssets\System\Images" mkdir "jp.ricoh.com\-\media\ScAssets\System\Images"
curl -L -o "jp.ricoh.com\-\media\ScAssets\System\Images\favicon.ico" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/media/ScAssets/System/Images/favicon.ico?rev=813ca5df9c8c408984ff573df66dd6c9"

rem [SKIP-POST] https://www.google-analytics.com/g/collect?v=2&tid=G-NQ01T89XSX&gtm=45je6611v876718451z8867447766za2
rem [SKIP-POST] https://www.google-analytics.com/g/collect?v=2&tid=G-1W7QW96RNV&gtm=45je6611v883120914z8867447067za2
if not exist "jp.ricoh.com\layouts\system" mkdir "jp.ricoh.com\layouts\system"
curl -L -o "jp.ricoh.com\layouts\system\VisitorIdentification.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/layouts/system/VisitorIdentification.js"

echo 完了