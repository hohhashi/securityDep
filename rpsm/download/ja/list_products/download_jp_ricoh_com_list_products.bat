@echo off
rem download_jp_ricoh_com_filter_list_products.bat
rem list_products ページのリソースをダウンロードする

rem .vscode と jp.ricoh.com を削除して再作成
if exist .vscode rmdir /s /q .vscode
if exist jp.ricoh.com rmdir /s /q jp.ricoh.com

mkdir "jp.ricoh.com\security\products\vulnerabilities"
curl -L -o "jp.ricoh.com\security\products\vulnerabilities\list_products.html" "https://jp.ricoh.com/security/products/vulnerabilities/list_products"

mkdir "jp.ricoh.com\layouts\system"
curl -L -o "jp.ricoh.com\layouts\system\VisitorIdentification.js" "https://jp.ricoh.com/layouts/system/VisitorIdentification.js"

mkdir "jp.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\Lib\jquery.min.js" "https://jp.ricoh.com/-/Media/ScAssets/System/Lib/jquery.min.js"

mkdir "jp.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\Lib\jquery.bxslider.min.js" "https://jp.ricoh.com/-/Media/ScAssets/System/Lib/jquery.bxslider.min.js"

mkdir "jp.ricoh.com\-\Media\ScAssets\System\Lib\bxslider"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\Lib\bxslider\jquery.bxslider.css" "https://jp.ricoh.com/-/Media/ScAssets/System/Lib/bxslider/jquery.bxslider.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\jquery-match-height.js" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/jquery-match-height.js"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\solution-product-template.js" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/solution-product-template.js"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\template.js" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/template.js"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\init.js" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/init.js"

mkdir "jp.ricoh.com\Scripts\dist\lib"
curl -L -o "jp.ricoh.com\Scripts\dist\lib\vendor.js" "https://jp.ricoh.com/Scripts/dist/lib/vendor.js"

mkdir "jp.ricoh.com\-\Media\ScAssets\System\JS"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\JS\common.js" "https://jp.ricoh.com/-/Media/ScAssets/System/JS/common.js"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\import.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/import.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\solution-product-template.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/solution-product-template.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\globalnavi.js" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/globalnavi.js"

mkdir "jp.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "jp.ricoh.com\-\Media\ScAssets\System\Lib\jquery.tile.js" "https://jp.ricoh.com/-/Media/ScAssets/System/Lib/jquery.tile.js"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video\jquery.magnific-popup.min.js" "https://jp.ricoh.com/-/Media/Ricoh/Common/modal-for-video/jquery.magnific-popup.min.js"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video\jquery.modal-for-video.js" "https://jp.ricoh.com/-/Media/Ricoh/Common/modal-for-video/jquery.modal-for-video.js"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video\youtube_modal_setting.js" "https://jp.ricoh.com/-/Media/Ricoh/Common/modal-for-video/youtube_modal_setting.js"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\modal-for-video\magnific-popup.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/modal-for-video/magnific-popup.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\css\template.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/css/template.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\common.vanilla.js" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/common.vanilla.js"

mkdir "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\css\list_products.css" "https://jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh/security/products/vulnerabilities/css/list_products.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v1\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v1\css\component.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v1/css/component.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo\logo.svg" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/logo/logo.svg"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\globe.svg" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/globe.svg"

mkdir "jp.ricoh.com\-\media\Ricoh\Sites\jp_ricoh\products\img"
curl -L -o "jp.ricoh.com\-\media\Ricoh\Sites\jp_ricoh\products\img\img_01.webp" "https://jp.ricoh.com/-/media/Ricoh/Sites/jp_ricoh/products/img/img_01.webp"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\blank-grey.svg" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/blank-grey.svg"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\blank-white.svg" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/blank-white.svg"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\youtube-icon.png" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/youtube-icon.png"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\facebook.png" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/facebook.png"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\x.svg" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/x.svg"

mkdir "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Sites\jp_ricoh\security\products\vulnerabilities\js\list_products.js" "https://jp.ricoh.com/-/Media/Ricoh/Sites/jp_ricoh/security/products/vulnerabilities/js/list_products.js"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\initBase.js" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/initBase.js"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\sc_reset.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/sc_reset.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\reset.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/reset.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\print.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/print.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\gl_header.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/gl_header.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\gl_footer.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/gl_footer.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\option.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/option.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\common.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/common.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\sc_common.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/sc_common.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cookie-management\css"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cookie-management\css\common.css" "https://jp.ricoh.com/-/Media/Ricoh/Common/cookie-management/css/common.css"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\templateBase.html" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\search.svg" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/search.svg"

mkdir "jp.ricoh.com\-\media\ScAssets\System\Images"
curl -L -o "jp.ricoh.com\-\media\ScAssets\System\Images\favicon.ico" "https://jp.ricoh.com/-/media/ScAssets/System/Images/favicon.ico"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg\arrow-right-primary-color.svg" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/svg/arrow-right-primary-color.svg"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v1\img"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v1\img\icon_s_right_01.png" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v1/img/icon_s_right_01.png"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v1\img"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v1\img\icon_s_last_01.png" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v1/img/icon_s_last_01.png"

mkdir "jp.ricoh.com\layouts\system"
curl -L -o "jp.ricoh.com\layouts\system\VisitorIdentificationCSS.aspx" "https://jp.ricoh.com/layouts/system/VisitorIdentificationCSS.aspx"

mkdir "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img"
curl -L -o "jp.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\icon_anchor_top.svg" "https://jp.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/icon_anchor_top.svg"

echo 完了
pause