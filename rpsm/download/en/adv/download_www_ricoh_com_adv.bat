@echo off
rem download_www_ricoh_com_adv.bat

if exist .vscode rmdir /s /q .vscode
if exist www.ricoh.com rmdir /s /q www.ricoh.com

mkdir "www.ricoh.com\products\security\vulnerabilities"
curl -L -o "www.ricoh.com\products\security\vulnerabilities\adv.html" "https://www.ricoh.com/products/security/vulnerabilities/adv"

mkdir "www.ricoh.com\layouts\system"
curl -L -o "www.ricoh.com\layouts\system\VisitorIdentification.js" "https://www.ricoh.com/layouts/system/VisitorIdentification.js"

mkdir "www.ricoh.com\layouts\system"
curl -L -o "www.ricoh.com\layouts\system\VisitorIdentificationCSS.aspx" "https://www.ricoh.com/layouts/system/VisitorIdentificationCSS.aspx"

mkdir "www.ricoh.com\Scripts\dist\lib"
curl -L -o "www.ricoh.com\Scripts\dist\lib\vendor.js" "https://www.ricoh.com/Scripts/dist/lib/vendor.js"

mkdir "www.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\Lib\jquery.min.js" "https://www.ricoh.com/-/Media/ScAssets/System/Lib/jquery.min.js"

mkdir "www.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\Lib\jquery.bxslider.min.js" "https://www.ricoh.com/-/Media/ScAssets/System/Lib/jquery.bxslider.min.js"

mkdir "www.ricoh.com\-\Media\ScAssets\System\Lib\bxslider"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\Lib\bxslider\jquery.bxslider.css" "https://www.ricoh.com/-/Media/ScAssets/System/Lib/bxslider/jquery.bxslider.css"

mkdir "www.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\Lib\jquery.tile.js" "https://www.ricoh.com/-/Media/ScAssets/System/Lib/jquery.tile.js"

mkdir "www.ricoh.com\-\Media\ScAssets\System\JS"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\JS\common.js" "https://www.ricoh.com/-/Media/ScAssets/System/JS/common.js"

mkdir "www.ricoh.com\-\Media\ScAssets\System\CSS"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\CSS\sc_common_us.css" "https://www.ricoh.com/-/Media/ScAssets/System/CSS/sc_common_us.css"

mkdir "www.ricoh.com\-\media\ScAssets\System\Images"
curl -L -o "www.ricoh.com\-\media\ScAssets\System\Images\favicon.ico" "https://www.ricoh.com/-/media/ScAssets/System/Images/favicon.ico"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\jquery-match-height.js" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/jquery-match-height.js"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\solution-product-template.js" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/solution-product-template.js"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\globalnavi.js" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/globalnavi.js"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\common.vanilla.js" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/common.vanilla.js"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\import.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/import.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\solution-product-template.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/solution-product-template.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\sc_reset.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/sc_reset.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\reset.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/reset.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\print.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/print.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\gl_header.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/gl_header.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\gl_footer.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/gl_footer.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\option.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/option.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\common.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/common.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\sc_common.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/sc_common.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg\blank-primary-color.svg" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/svg/blank-primary-color.svg"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg\arrow-right-primary-color.svg" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/svg/arrow-right-primary-color.svg"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\template.js" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/template.js"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\init.js" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/init.js"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\initBase.js" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/initBase.js"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\templateBase" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\templateBase.js" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\css\template.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/css/template.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo\logo.svg" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/logo/logo.svg"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\globe.svg" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/globe.svg"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\search.svg" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/search.svg"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video\jquery.magnific-popup.min.js" "https://www.ricoh.com/-/Media/Ricoh/Common/modal-for-video/jquery.magnific-popup.min.js"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video\jquery.modal-for-video.js" "https://www.ricoh.com/-/Media/Ricoh/Common/modal-for-video/jquery.modal-for-video.js"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video\youtube_modal_setting.js" "https://www.ricoh.com/-/Media/Ricoh/Common/modal-for-video/youtube_modal_setting.js"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video\magnific-popup.css" "https://www.ricoh.com/-/Media/Ricoh/Common/modal-for-video/magnific-popup.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Common\cookie-management\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cookie-management\css\common.css" "https://www.ricoh.com/-/Media/Ricoh/Common/cookie-management/css/common.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\js\adv.js" "https://www.ricoh.com/-/Media/Ricoh/Sites/com/products/security/vulnerabilities/js/adv.js"

mkdir "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\css\sheet.css" "https://www.ricoh.com/-/Media/Ricoh/Sites/com/products/security/vulnerabilities/css/sheet.css"

mkdir "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\img"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\img\ic_important.svg" "https://www.ricoh.com/-/Media/Ricoh/Sites/com/products/security/vulnerabilities/img/ic_important.svg"

echo done
pause