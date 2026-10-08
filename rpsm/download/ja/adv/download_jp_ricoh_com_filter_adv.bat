@echo off
rem HARから生成したcurlコマンド一覧
rem jp.ricoh.com filter_adv - 2026/06/09
rem URLのパス構造をそのままフォルダとして再現します
rem 実行: download_jp_ricoh_com_filter_adv.bat

if exist ".vscode" rmdir /s /q ".vscode"
if exist "jp.ricoh.com" rmdir /s /q "jp.ricoh.com"

set UA=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
set REF=https://jp.ricoh.com/

if not exist "jp.ricoh.com\security\products\vulnerabilities" mkdir "jp.ricoh.com\security\products\vulnerabilities"
curl -L -o "jp.ricoh.com\security\products\vulnerabilities\adv.html" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/security/products/vulnerabilities/adv?id=ricoh-prod000263-2026-000004"

if not exist "jp.ricoh.com\layouts\system" mkdir "jp.ricoh.com\layouts\system"
curl -L -o "jp.ricoh.com\layouts\system\VisitorIdentification.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/layouts/system/VisitorIdentification.js"

if not exist "jp.ricoh.com\-\Media\ScAssets\System\Lib" mkdir "jp.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\Lib\jquery.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/ScAssets/System/Lib/jquery.min.js?cacheDate=202606091242"

if not exist "jp.ricoh.com\-\Media\ScAssets\System\Lib" mkdir "jp.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\Lib\jquery.bxslider.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/ScAssets/System/Lib/jquery.bxslider.min.js?cacheDate=202606091242"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\jquery-match-height.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/jquery-match-height.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\solution-product-template.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/solution-product-template.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\template.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/template.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\init.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/init.js"

if not exist "jp.ricoh.com\Scripts\dist\lib" mkdir "jp.ricoh.com\Scripts\dist\lib"
curl -L -o "jp.ricoh.com\Scripts\dist\lib\vendor.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/Scripts/dist/lib/vendor.js?cacheDate=202606091242"

if not exist "jp.ricoh.com\-\Media\ScAssets\System\JS" mkdir "jp.ricoh.com\-\Media\ScAssets\System\JS"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\JS\common.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/ScAssets/System/JS/common.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\globalnavi.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/globalnavi.js?cacheDate=202606091242"

if not exist "jp.ricoh.com\-\Media\ScAssets\System\Lib" mkdir "jp.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\Lib\jquery.tile.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/ScAssets/System/Lib/jquery.tile.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video\jquery.magnific-popup.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/modal-for-video/jquery.magnific-popup.min.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video\jquery.modal-for-video.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/modal-for-video/jquery.modal-for-video.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video\youtube_modal_setting.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/modal-for-video/youtube_modal_setting.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\common.vanilla.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/common.vanilla.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo\logo.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/logo/logo.svg"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\globe.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/globe.svg"

if not exist "jp.ricoh.com\-\media\Ricoh\Sites\jp_ricoh\products\img" mkdir "jp.ricoh.com\-\media\Ricoh\Sites\jp_ricoh\products\img"
curl -L -o "jp.ricoh.com\-\media\Ricoh\Sites\jp_ricoh\products\img\img_01.webp" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/media/Ricoh/Sites/jp_ricoh/products/img/img_01.webp?rev=8fa319fe325047019db019d2d41e6101&sc_lang=ja-JP&hash=7729B57BE17E5585FF5BCCAEEACEAB98"

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

if not exist "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\js\adv.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh/security/products/vulnerabilities/js/adv.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\initBase.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/initBase.js"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\templateBase.html" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\search.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/search.svg"

if not exist "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg" mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg\blank-primary-color.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/svg/blank-primary-color.svg"

if not exist "jp.ricoh.com\-\media\ScAssets\System\Images" mkdir "jp.ricoh.com\-\media\ScAssets\System\Images"
curl -L -o "jp.ricoh.com\-\media\ScAssets\System\Images\favicon.ico" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://jp.ricoh.com/-/media/ScAssets/System/Images/favicon.ico?rev=813ca5df9c8c408984ff573df66dd6c9&sc_lang=ja-JP"
