/* 
  
  ---
  
  jquery.modal-for-video.js
  
  書式
  $( 'jQueryセレクタ文字列' ).modalForVideo( 'パラメータ文字列[省略可能]' );
  
  ・Youtube埋め込みモーダルを簡易な記載で設置できます（magnificPoppu使用）
  ・モーダルで動的に生成されるiFrameをGAで計測するために、パラメータにenablejsapi=1を付与します。
  ・jquery, magnific-popup, modal-for-videoの順に読み込んでから使用してください。
  
  ※対象となるaタグのhref属性にyoutubeのURL（短縮URLでないもの。watch?v=が必ず含まれるもの。embed用のアドレスではありません）を記載してください。
  
  ---
  
  書式例１（デフォルトパラメータで良い場合）
  $('対象aタグのセレクタ').modalForVideo();
    セレクタ例：　'a[href*="youtube.com/watch"]'　→ youtubeのアドレスがhrefに記載されている全てのaタグが対象
  
  ---
  
  書式例２（パラメータを指定する場合）
  $('対象aタグのセレクタ').modalForVideo('?mute=1&playsinline=1&rel=0&autoplay=1');
  
  パラメータはiframeのsrc属性に付与されるパラメータ値です
    デフォルト　'rel=0&autoplay=1'
    
  ※この他にenablejsapi=1は必ず付与されます。
  
  ---
  
  書式例３（mfpのイベントのコールバックを指定する場合）
  イベント名は　「mfp」 + 「magnific-popupイベント名のuppercase」　というルールで使用します。詳細は
    https://dimsemenov.com/plugins/magnific-popup/documentation.html#api
  のEventsの説明内にある　Alternative method: using events　の項目を参照してください。
  
  $('対象aタグのセレクタ').on({
    'mfpOpen': function(){
      // magnific-popupのopen時の処理
    },
    'mfpAfterClose': function(){
      // magnific-popupのafterClose時の処理
    }
  }).modalForVideo();
  
  ---
  
*/


(function( $ ) {
  
  $.fn.modalForVideo = function( srcParams ) {
    
    //動画パラメータ設定
    var _srcParams = srcParams === undefined ? 'rel=0&autoplay=1' : srcParams;
    
    //パラメータ抽出
    var _getParam = function(name, url) {
      name = name.replace(/[\[\]]/g, "\\$&");
      var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
      if (!results) return null;
      if (!results[2]) return '';
      return decodeURIComponent(results[2].replace(/\+/g, " "));
    }
    
    //mfp呼び出し
    return this.magnificPopup({
      type: 'iframe',
      iframe: {
        markup: '<div class="mfp-iframe-scaler">' +
          '<div class="mfp-close"></div>' +
          '<iframe class="mfp-iframe" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>' +
          '</div>',
        patterns: {
          youtube: {
            index: 'youtube.com',
            id: function(url) {
              return _getParam('v', url);
            },
            src: 'https://www.youtube.com/embed/%id%?enablejsapi=1&' + _srcParams
          }
        }
      }
    });

  }
  
})( jQuery );


//iframe_api読み込み
var tag = document.createElement('script');
tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
