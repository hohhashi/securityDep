/**
 * common.js
 */

;(function($) {
  //===================================== init var
  var $window;

  //===================================== document ready
  $(function() {
    $window = $(window);

    var browser = getBrowser();
    var device = getDevice();
    var breakPoint = 640;

    //window load resize action
    $window.on('load resize', function(e){
      if ( e.type === 'load' ) {
        //uniform selectbox
        //required jquery.uniform.js
        if( $('select.uniform')[0] && browser !== 'ie7' && browser !== 'ie8' ){
          $('select.uniform').uniform({
            selectAutoWidth: false
          });
        }
      }
      alignHeight();
    });

    //local scroll --------------------------------------
    $('.smoothScroll').find('[href^="#"]').click(function(e){
      var $trigger = $(this);
      var targetId = $trigger.attr('href').replace('#', '');
      var $targetBlock = $('#' + targetId);
      if ($targetBlock.size() > 0) {
        $('html, body').stop().animate({ scrollTop: $targetBlock.offset().top }, 500);
      }else{
        $('html, body').stop().animate({ scrollTop: 0 }, 500);
      }
      e.preventDefault();
      return false;
    });

    /**
     * initialize accordion for small screen
     */
    function initSmallScreenAccordion() {
      var $smallAccordionTitles = $('.smallAccordionTitle');
      var $smallAccordionContents = $('.smallAccordionContent');

      var smallScreenAccordionOpenClassName = 'open';

      if( $smallAccordionTitles[0] === undefined ){
        return;
      }

      $smallAccordionTitles.each(function(index){
        var $this = $(this);
        $this.data('titleIndex', index);

        $this.click(function(e){
          var $clickedObj =  $(this);
          var index = $clickedObj.data('titleIndex');
          var $content = $smallAccordionContents.eq(index);

          if( !$content.hasClass(smallScreenAccordionOpenClassName) ){
            $this.addClass(smallScreenAccordionOpenClassName);
          }

          $content.not(':animated').slideToggle(200, function(e){
            var $this = $(this);

            $this.toggleClass(smallScreenAccordionOpenClassName);

            if( $this.css('display') === 'block' ){
              scrollToWithjQueryObject($clickedObj);
              $this.data('opened', true);
              alignHeight();
            }else{
              $clickedObj.removeClass(smallScreenAccordionOpenClassName);
              $this.data('opened', false);
            }
            $this.removeAttr('style');
          });

          e.preventDefault();
          return false;
        });
      });

      $window.on('resize', function(){
        if( getViewport().width > breakPoint ){
          $smallAccordionContents.addClass(smallScreenAccordionOpenClassName);
        }else{
          $smallAccordionContents.removeClass(smallScreenAccordionOpenClassName);
          $smallAccordionContents.each(function(index){
            var $this = $(this);

            if( $this.data('opened') ){
              $smallAccordionTitles.eq(index).addClass(smallScreenAccordionOpenClassName);
              $this.addClass(smallScreenAccordionOpenClassName);
            }
          });
        }
      });
    }

    initSmallScreenAccordion();
    // accordion for small screen ------------------------------

    /**
     * initialize bx slider
     * required jquery.bxslider.min.js
     */
    function initBxslider() {
      var $slider = $('#slider');

      if( $slider[0] === undefined ){
        return;
      }

      var sliderElmChild =  $slider.find('li').length;
      if(sliderElmChild < 2){
        return;
      }

      var obj = $slider.bxSlider({
        auto: true,
        pause: 5000,
        speed: 800,
        pager: true,
        controls: true,
        touchEnabled: true,
        autoControlsCombine: true,
        autoControls: true,
        onSliderLoad: function () {
          var $slidecntrlPager = $('.bxsld_pager').css('display', 'inline-block');
          var $slidecntrlAuto = $('.bxsld_controls-auto').css('display', 'inline-block');
          var $slidecntrlCntrlset = $('<div class="bxsld_controls-pager-auto" />');
          $slidecntrlCntrlset.append($slidecntrlAuto).append($slidecntrlPager);
          $slidecntrlCntrlset.prependTo($('.bxsld_controls'));
          var $slidecntrlDirBgPrev = $('<div class="bxsld_controls_dirction_bg_prev" />');
          var $slidecntrlDirBgNext = $('<div class="bxsld_controls_dirction_bg_next" />');
          $('.bxsld_controls-direction').append($slidecntrlDirBgPrev).append($slidecntrlDirBgNext);

          var getHash = location.hash;
          if(getHash){
            var $html = $('html, body');
            var getIdPos = $(getHash).position();
            $html.scrollTop(getIdPos.top);
          }

          _heightAdjust();

        },
        onSliderResize: function(){
          _heightAdjust();
        },
        onSlideBefore: function () {
          if( device === 'android' || device === 'iphone' || device === 'ipad' ){
            var $pagerItemAnchor = $('.bxsld_pager-item a');
            $pagerItemAnchor.addClass('smartphone');
          }
        },
        onSlideAfter: function () {
        }
      });

      function _heightAdjust() {
        var $mainViDevice = $slider.find('.main_vi_device');
        if($mainViDevice.length > 0){
          $mainViDevice.css({'height' : 'auto'});
          var largeHeight = 0;
          $mainViDevice.each(function(){
            var getHeight = $(this).height();
            if(getHeight > largeHeight){
              largeHeight = getHeight;
            }
          });
          $mainViDevice.css({'height' : largeHeight + 'px'});
        }
      }

    }

    initBxslider();
    //bx slider ------------------------------

    /**
     * align height
     * required jquery.tile.js
     */
    function alignHeight() {
      var $tileSameRoots = $('.tileSame');

      if( $tileSameRoots[0] === undefined ){
        return;
      }

      for( var i = 0, l = $tileSameRoots.length; i < l; i++ ){
        var $tileSameRoot = $tileSameRoots.eq(i);
        var $cells = $tileSameRoot.find('[class*="tlSame"]');

        if( $cells[0] === undefined || $tileSameRoot.css('height').replace('px', '') <= 0 || $tileSameRoot.css('display') === 'none' ){
          continue;
        }

        var tiledClassNameArray = [];
        for( var j = 0, jl = $cells.length; j < jl; j++ ){
          if( $cells.eq(j).css('height').replace('px', '') <= 0 || $cells.eq(j).css('display') === 'none' ){
            continue;
          }

          var className = $cells.eq(j).attr('class');
          var startIndex = className.indexOf('tlSame');

          var noPrefixHl = className.substring(startIndex, className.length);

          var endIndex = noPrefixHl.search(/ /);

          var hlClassName;
          if( endIndex !== -1 ){
            hlClassName = noPrefixHl.substring(0, endIndex);
          }else{
            hlClassName = noPrefixHl;
          }

          if( $.inArray(hlClassName, tiledClassNameArray) === -1 ){
            var $groupCells = $tileSameRoot.find('.' + hlClassName);
            var firstOffset = $groupCells.eq(0).offset().top;
            var numberOfColumn = 0;
            for( var k = 0, kl = $groupCells.length; k < kl; k++  ){
              if( firstOffset !== $groupCells.eq(k).offset().top ){
                numberOfColumn = k;
                break;
              }
            }

            $groupCells.tile(numberOfColumn);
            tiledClassNameArray[tiledClassNameArray.length] = hlClassName;
          }
        }
      }
    }
    //align height ------------------------------

    /**
     *  initialize responsiveTabs
     *  required jquery.responsiveTabs.js
     */
    function initTabAccordion(){
      var $accordionTab = $('.tabAccordion');

      if( $accordionTab[0] ){
        $accordionTab.responsiveTabs();
      }
    }
    initTabAccordion();
    //initialize responsiveTabs ------------------------------

    /**
     *  initialize normalTab
     */
    function initNormalTab(){
      var $tabWrapper = $('div.tabNormal');

      if( $tabWrapper[0] === undefined ){
        return;
      }

      var tabActiveClassName = 'act';

      $tabWrapper.each(function() {
        var $tabWrap = $(this);
        var $tabUl = $tabWrap.find('.tabNormalTitle');
        var $tabTriggerLi = $tabUl.find('li');
        var $tabTriggerBtn = $tabTriggerLi.children('a');
        var $tabContent = $tabWrap.find('.tabNormalDetail');
        var tabOpenClassName = 'open';

        // a11y対応フラグ判定
        var a11yFlag = false;
        if ($tabWrap.hasClass('a11y_tab_sct')) {
          a11yFlag = true;
        }

        $tabUl.css('display', 'block');

        $tabTriggerLi.eq(0).addClass(tabActiveClassName);
        $tabContent.eq(0).addClass(tabActiveClassName);

        // a11y対応
        if (a11yFlag) {
          $tabTriggerBtn.attr('aria-selected', 'false');
          $tabTriggerBtn.eq(0).attr('aria-selected', 'true');
        }

        $tabTriggerLi.each(function(index) {
          var $li = $(this);
          var $a = $li.children('a');

          $a.data('tabIndex', index);

          $a.click(function (e) {
            var $trigger = $(this);
            var thisIndex = $trigger.data('tabIndex');

            $tabTriggerLi.removeClass(tabActiveClassName);
            $tabContent.removeClass(tabActiveClassName);
            $trigger.parent('li').addClass(tabActiveClassName);
            $tabContent.eq(thisIndex).addClass(tabActiveClassName);

            // a11y対応
            if (a11yFlag) {
              $tabTriggerBtn.attr('aria-selected', 'false');
              $trigger.attr('aria-selected', 'true');
            }

            if ($tabContent.eq(thisIndex).find('.tileSame').size() > 0) {
              alignHeight();
            }

            e.preventDefault();
            return false;
          });
        });
      });
    }
    initNormalTab();
    // initialize normalTab --------------------------

    /**
     * initialize accordion
     */
    function initAccordionSct(){
      var $acoDtl = $('.accordionDetail');

      var acoTtlClassName = ('.accordionTitle');

      var $singleLink_acd_ttl = $('.accordionSingleLink .accordionTitle');
      var activeClassName = ('open');

      // $acoDtl.hide();
      // $acoDtl.removeClass(activeClassName);

      $singleLink_acd_ttl.click(function () {
        var $clickedObj = $(this);
        var $content = $clickedObj.parent().find('.accordionDetail');

        if( !$content.hasClass(activeClassName) ){
          $clickedObj.addClass(activeClassName);
        }

        $content.not(':animated').slideToggle(200, function(e){
          var $this = $(this);

          $this.toggleClass(activeClassName);

          if( $this.css('display') === 'block' ){
            scrollToWithjQueryObject($clickedObj);
            alignHeight();
          }else{
            $clickedObj.removeClass(activeClassName);
          }
        });
      });
    }

    initAccordionSct();

    function defaultOpenAccordion(){
      var activeClassName = ('open');

      var $defaultOpen = $('.defaultOpen');

      $defaultOpen.children('.accordionSingleLink .accordionTitle, .accordionSingleLink .accordionDetail').addClass(activeClassName);
      $defaultOpen.children('.accordionDetail').show();

    }

    defaultOpenAccordion();
    // initialize accordion --------------------------

    /**
     * initialize smallImage
     */
    function initSmallImage(){
      var smallImageClassName = 'smallImage'; //class 名の指定
      var $originsmallImages = $('.' + smallImageClassName);
      var hiddenOriginImageClassName = 'hidden';

      if( $originsmallImages[0] === undefined ){
        return;
      }

      var $triggers = $('.smallImageTrigger');

      var $contentsWrapper = $('div.largeContentsWrapper');
      if( $contentsWrapper[0] === undefined ){
        $contentsWrapper = $('body').wrapInner('<div class="largeContentsWrapper"></div>').find('div.largeContentsWrapper');
      }
      //var $contentsWrapper = $('body').wrapInner('<div class="largeContentsWrapper"></div>').find('div.largeContentsWrapper');
      var $smallImageWrapper = $('<div class="img_wrapper smallImageWrapper" />').append('<p class="img_btn backBtn"><a class="ico_nml_lf left_lf" href="javascript:void(0)">Back</a></p>');
      var $backBtn = $smallImageWrapper.find('.backBtn');
      var originScrollTop = 0;

      $contentsWrapper.before($smallImageWrapper);
      changeLayout();

      $triggers.each(function(index){
        var $trigger = $(this);

        $trigger.data('triggerIndex', index);

        $trigger.click(function(e){
          var index = $trigger.data('triggerIndex');
          var $originsmallImage = $originsmallImages.eq(index);
          var $smallImage = $originsmallImage.clone(true).css('display', 'block');

          originScrollTop = $window.scrollTop();

          $smallImageWrapper.append($smallImage);
          $contentsWrapper.css('display', 'none');
          $smallImageWrapper.css('display', 'block');

          $("meta[name='viewport']").attr('content', 'width=1200, initial-scale=1.0, maximum-scale=2.0, user-scalable=yes');


          $('body, html').scrollTop(0);
        });
      });

      $backBtn.find('a').click(function(e){
        hidesmallImage();
        $smallImageWrapper.find('.' + smallImageClassName).remove();

        $("meta[name='viewport']").attr('content', 'width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no');


        e.preventDefault();
        return false;
      });

      $window.resize(function(e){
        changeLayout();
      });

      $window.scroll(function(e){
        var offsetLeft = $(this).scrollLeft();

        $backBtn.css('margin-left', offsetLeft);
      });

      /**
       * show small Image
      */
      function showsmallImage(){
        $contentsWrapper.css('display', 'none');
        $smallImageWrapper.css('display', 'block');
      }

      /**
       * hide small Image
      */
      function hidesmallImage(){
        $contentsWrapper.css('display', 'block');
        $('body, html').scrollTop(originScrollTop);
        $smallImageWrapper.css('display', 'none');
      }

      /**
       *  change layout
       */
      function changeLayout() {
        if( getViewport().width > breakPoint ){
          $originsmallImages.removeClass(hiddenOriginImageClassName);

          if( $smallImageWrapper.find('.' + smallImageClassName)[0] ){
            hidesmallImage();
          }
        }else{
          $originsmallImages.addClass(hiddenOriginImageClassName);

          if( $smallImageWrapper.find('.' + smallImageClassName)[0] ){
            showsmallImage();

          }
        }
      }
    }
    initSmallImage();
    // initialize smallImage --------------------------

    /**
     *  scroll with animation when accordion opened.
     *
     *  @param {$} $obj jQuery Object
     *  when accordion open, scroll to $obj
     */
    function scrollToWithjQueryObject( $obj ){
      var offsetTop = $obj.offset().top;
      var slideDurationSP = 400;

      $('body, html').animate(
        { 'scrollTop':  offsetTop}, slideDurationSP
      );
    }
    // scrollToWithjQueryObject ---------------------


    /**
     *  get viewport
     */
    function getViewport() {
      var e = window, a = 'inner';
      if (!('innerWidth' in window )) {
        a = 'client';
        e = document.documentElement || document.body;
      }
      return { width : e[ a+'Width' ] , height : e[ a+'Height' ] };
    }

    //check browser
    /**
     *  get browser name
     *
     *  @return     browser name(ie6, ie7, ie8, ie9, ie10, ie11, chrome, safari, opera, firefox, unknown)
     *
     */
    function getBrowser() {
      var userAgent = window.navigator.userAgent.toLowerCase();
      var appVersion = window.navigator.appVersion.toLowerCase();
      var browserName = 'unknown';

      if (userAgent.indexOf('msie') !== -1){
        if (appVersion.indexOf('msie 6.') !== -1){
          browserName = 'ie6';
        }else if (appVersion.indexOf('msie 7.') !== -1){
          browserName = 'ie7';
        }else if (appVersion.indexOf('msie 8.') !== -1){
          browserName = 'ie8';
        }else if (appVersion.indexOf('msie 9.') !== -1){
          browserName = 'ie9';
        }else if (appVersion.indexOf('msie 10.') !== -1){
          browserName = 'ie10';
        }else{
          browserName = 'ie';
        }
      }else if(userAgent.indexOf('trident/7') !== -1){
        browserName = 'ie11';
      }else if (userAgent.indexOf('chrome') !== -1){
        browserName = 'chrome';
      }else if (userAgent.indexOf('safari') !== -1){
        browserName = 'safari';
      }else if (userAgent.indexOf('opera') !== -1){
        browserName = 'opera';
      }else if (userAgent.indexOf('firefox') !== -1){
        browserName = 'firefox';
      }
      return browserName;
    }
    // getBrowser ------------------------------

    /**
     *  get device
     *
     *  @return     device name(iphone, ipad, android, other)
     *
     */
    function getDevice() {
      var userAgent = window.navigator.userAgent.toLowerCase();
      var deviceName = 'other';

      if ( userAgent.indexOf('iphone') !== -1 ){
        deviceName = 'iphone';
      }else if ( userAgent.indexOf('ipad') !== -1 ){
        deviceName = 'ipad';
      }else if ( userAgent.indexOf('android') !== -1 ){
        deviceName = 'android';
      }
      return deviceName;
    }
    // getDevice ------------------------------

    /**
     *  local navi (based on products scripts.js)
     */
    function localNavi() {
      if (!document.getElementsByClassName('local_nv')[0]) {
        return;
      }

      // [PC]
      // Navi Set Fixed
      var tab_pc = $('.local_nv_pc .local_nv'),
      offset_pc = tab_pc.offset();

      $(window).scroll(function () {
        if($(window).scrollTop() > offset_pc.top) {
          tab_pc.addClass( 'fixed' );
        } else {
          tab_pc.removeClass( 'fixed' );
        }
      });

      //Anchor Scroll
      $('.local_nv_pc .local_nv a').click(function(){
        var href = $(this).attr("href");
        var target = $(href == "#" || href == "" ? 'html' : href);
        var navHeight = tab_pc.height() + 20;
        if (!tab_pc.hasClass('fixed')) {
          navHeight = navHeight * 2 + 13;
        }
        var position = target.offset().top - navHeight;
        $("html, body").animate({scrollTop:position}, 500 );
        return false;
      });

      // [SP]
      // Navi Set Fixed
      var tab_sp = $('.local_nv_sp .local_nv'),
      offset_sp = tab_sp.offset();

      $(window).scroll(function () {
        if($(window).scrollTop() > offset_sp.top) {
          tab_sp.addClass( 'fixed' );
        } else {
          tab_sp.removeClass( 'fixed' );
        }
      });

      // Navi Menu
      $('.local_nv_sp .local_nv_ttl').on('click', function () {
        $(".local_nv_sp .local_menu").slideToggle( 400, 'swing' );
        $(".local_nv_sp .local_nv_ttl  span").toggleClass('local_close');
      });

      //Anchor Scroll
      $('.local_nv_sp .local_menu a').click(function(){
        $(".local_nv_sp .local_menu").slideUp( 200, 'swing' );
        $(".local_nv_sp .local_nv_ttl span").removeClass('local_close');
        var href = $(this).attr("href");
        var target = $(href == "#" || href == "" ? 'html' : href);
        var navHeight = tab_sp.height();
        if (!tab_sp.hasClass('fixed')) {
          navHeight = navHeight + 16;
        }
        console.log(navHeight);
        var position = target.offset().top - navHeight;
        $("html, body").animate({scrollTop:position}, 500 );
        return false;
      });
    }
    localNavi();
    // localNavi ------------------------------

    /**
     *  pagetop button (based on ricoh.com)
     */
    function pageTop() {
      if (!document.getElementsByClassName('cp-PageTop')[0]) {
        return;
      }
      var topBtn = $('.cp-PageTop');
      topBtn.hide();

      //Fade In Scroll
      $(window).scroll(function () {
        if ($(this).scrollTop() > 250) {
          topBtn.fadeIn();
        } else {
          topBtn.fadeOut();
        }
      });
    }
    pageTop();
    // pageTop ------------------------------

    /**
     *  cpStepUp (based on v1 extend)
     */
    function cpStepUp() {
      if (!document.getElementsByClassName('jp_step_current')[0]) {
        return;
      }
      var next_step=document.getElementsByClassName("current");
      var step=document.getElementsByClassName("jp_step_current");
      var next_step_before=$(next_step).prev();

      var property={
        "background-image":"url('/-/Media/ScAssets/System/Images/ex_component/arrow_nextstep_act_before.jpg')",
        "background-repeat":"no-repeat",
        "background-position":"right center"
      }

      $(next_step_before).css(property);
    }
    cpStepUp();
    // cpStepUp ------------------------------

    /**
     *  mapAccordion (based on map_accordion.js)
     */
    function mapAccordion() {
      $( '#acdn-button' ).click(function() {
        $( '#acdn-target' ).slideToggle() ;
        $( '.map_root_ttl' ).toggleClass( 'open' );
      });
    }
    mapAccordion();
    // mapAccordion ------------------------------

    /**
     *  table scroll (based on module2015-chase-module.js)
     */
    function tableScroll() {
      $(window).on('load', function() {
        var android2_3 = navigator.userAgent.match(/Android 2.3/); //Androis2.3かどうか判定

        $('.cp-RichText.isTableScroll table').not('table table').addClass('nml').addClass('nml_scroll');

        //ここからタッチ操作の本挙動
        $('table.nml_scroll').not('table table').each(function() {
          var $thisDom = $(this);
          var $root = $(this);

          $thisDom.wrap('<div class="nml_scrollAddWrap"></div>');
          if ($thisDom.get(0).tagName === 'TABLE') {
            $root = $thisDom.closest('.nml_scrollAddWrap');
          }

          //「結合されたセル」全てにwhite-space：nowrap;を付与(Android2.3で表組みの一部が欠けるバグ対策)
          if (android2_3) {
            $thisDom.find('th, td').each(function() {
              var $target = $(this);
              if ($target.attr('colspan') || $target.attr('rowspan')) {
                $target.css({
                  'white-space': 'nowrap'
                });
              }
            });
          }

          var $touchContents = $root.find('>table'), //タッチする要素（はみ出している部分を取得したい）
            pageX = 0, //横位置を取得するために必要
            startX = 0, //起点
            moveX = 0, //差
            posX = 0,
            　 //さっきまでいた位置　現在位置
            moveP = 0, //実際に動かす大きさ
            ratioBar = 0, //Barを動かす際の比率
            ratioChange = 0, //縦横切り替え時の比率計算に使用
            limitR = 0, //要素が左に行き過ぎないように
            $scrollBar = '',
            $scrollBarC = '',
            moveFlag = false, //tableの幅に応じて変化
            createBar = true,
            resizeFlag = false; //bar を出すかどうか

          var moveAction = function() {
            //タッチ開始
            $touchContents.on('touchstart', function(e) {
              pageX = event.changedTouches[0].pageX;
              startX = pageX;
            });

            // 移動中
            $touchContents.on('touchmove', function(e) {
              moveX = event.changedTouches[0].pageX - startX; //起点から今の指の位置との差　どれだけどの方向に動いたか
              if (moveFlag && Math.abs(moveX) > 20) { //もしフラグがtrueならば、スクロールをさせない　=　横スライドの判定がしやすくなる。
                e.preventDefault();
              }
              moveP = moveX + posX;
              if (moveP > 0) {
                moveP = 0
              }; //要素が右に行き過ぎないように
              if (Math.abs(moveP) > limitR) {
                moveP = -limitR;
              }; //要素が左に行き過ぎないように
              $touchContents.css('margin-left', moveP);
              $scrollBarC.css('left', -(moveP * ratioBar));

              //機種によりスクロールバーが後わずか残ってしまうのを回避
              //移動した距離が移動できる距離-1pxをこえると発動
              if (-(moveP * ratioBar) > (limitR * ratioBar - 0.2)) {
                $scrollBarC.css('left', -(moveP * ratioBar - 1)) //(Math.ceil(-moveP*ratioBar-1)));
              }
            });

            // タッチ終了
            $touchContents.on('touchend', function(e) {
              posX = moveP;
              ratioChange = posX / limitR;
            });
          }

          //スクロールバーを出す+取得+長さ＋比率　作成
          var createScrollBarDom = function() {
            var scrollBarDom = '<div class="scrollBar">';
            scrollBarDom += '<div class="scrollBarC">';
            scrollBarDom += '&nbsp;';
            scrollBarDom += '</div>';
            scrollBarDom += '</div>';
            $root.after(scrollBarDom); //作る
            createBar = false;
          }
          //スクロールバーの取得+長さ＋比率　作成
          var getScrollBarDom = function() {
            $scrollBar = $root.next('.scrollBar'), //取得
              $scrollBarC = $scrollBar.children(); //取得
            //バー本体は、整数にするさい、切り上げる。
            $scrollBarC.width(Math.ceil(Math.pow($root.width(), 2) / $touchContents.width()));
            ratioBar = $scrollBarC.width() / $root.width();
          }

          var judgeAction = function() {
            limitR = $touchContents.width() - $root.width();
            moveFlag = true;

            if ($touchContents.width() > $root.width()) { //tableが横長い場合、実行
              if (createBar) {
                createScrollBarDom();
              }
              getScrollBarDom();
              $scrollBar.removeClass('noVisual');
              moveAction();
            } else {
              $root.nextAll('.scrollBar').addClass('noVisual');
              moveFlag = false;
            }
          }
          //tableの幅を測定後、その大きさに大応じて、スクロールバーを出すなどを行い、見た目の準備を行う。
          //見た目作成後、moveActionを実行

          judgeAction();

          //画面のサイズ変更時 3gsの処理能力のため、時間差を設ける。
          var windowRecalculation = function() {
            setTimeout(function() {
              judgeAction();
              setTimeout(function() {
                if (isNaN(ratioChange)) {
                  ratioChange = 0;
                }
                moveP = ratioChange * limitR;

                $touchContents.css('margin-left', moveP);
                if ($scrollBarC) {
                  $scrollBarC.css('left', -(moveP * ratioBar));
                }
                posX = moveP;
              }, 1200);
            }, 800);
          }

          //リサイズ
          $(window).on('resize', function(e) {
            windowRecalculation();
          });

          //タブクリック
          $('.tab_ttl').find('a').click(function(e) {
            windowRecalculation();
          });
          $('.acd_ttl').find('a').click(function(e) {
            windowRecalculation();
          });
        });
      });
    }
    tableScroll();
    // tableScroll ------------------------------

    /**
     *  fade main image (based on v1jp fs_ricoh.js)
     */
    function fadeMainImg() {
      if (
        !document.getElementsByClassName('fade_mainimg')[0]
        && !document.getElementsByClassName('fade_mainimg01')[0]
      ) {
        return;
      }

      var $fade_mainimg = $('.fade_mainimg li img,.fade_mainimg01 li img');
      var $fade_subimg = $('.fade_subimg li');

      $fade_mainimg.eq(0).velocity({ opacity: 1 }, 1000);
      $fade_subimg.velocity({ opacity: 1 }, 1000);
      $fade_subimg.eq(0).addClass('on');

      $fade_subimg.bind('click', function(){
        var this_index = $(this).index();

        $fade_subimg.removeClass('on');
        $(this).addClass('on');
        $fade_mainimg.velocity({ opacity: 0 }, 400).css('z-index',0);
        $fade_mainimg.eq(this_index).velocity({ opacity: 1 }, 400).css('z-index',1);
      });
      $(window).bind("resize",onWinResize);
      onWinResize();

      function onWinResize() {
        var this_h = $fade_mainimg.css('height');
        $fade_mainimg.parent().parent().css('height', this_h);
      }
    }
    fadeMainImg();
    // fadeMainImg ------------------------------

    /**
     * initialize languageSelector
     */
    function initLanguageSelector() {
      var $header = $('#gl_header');

      var $langSelectorTrigger = $header.find('div.hd_ut_lang_select a.hd_ut_lang');
      var $langSelectorTxt = $langSelectorTrigger.find('.txt');
      var $langSelectorListUl = $header.find('div.hd_ut_lang_lst ul');
      var $langSelectorListAnchors = $langSelectorListUl.find('a');
      var languageOpenClassName = 'open';

      //clicked language selector
      $langSelectorTrigger.click(function(e){
        toggleLanguageSelector();

        e.preventDefault();
        return false;
      });

      //choiced language
      $langSelectorListAnchors.click(function(e){
        var $this = $(this);

        $langSelectorListAnchors.removeClass('act');
        $this.addClass('act');

        $langSelectorTxt[0].innerHTML = $this.find('span')[0].innerHTML;

        toggleLanguageSelector();
      });

      //clicked other dom
      $(document).click(function(e){
        var eventTarget = e.target;

        if( !$.contains( !$langSelectorTrigger[0], eventTarget) ||
            !$.contains( !$langSelectorListAnchors[0], eventTarget) ){
          hideLanguageSelector();
        }
      });

      /**
       *  toggle language selector
       */
      function toggleLanguageSelector() {
        $langSelectorTrigger.toggleClass(languageOpenClassName);
        $langSelectorListUl.toggleClass(languageOpenClassName);
      }

      /**
       *  hide language selector
       */
      function hideLanguageSelector() {
        $langSelectorTrigger.removeClass(languageOpenClassName);
        $langSelectorListUl.removeClass(languageOpenClassName);
      }
    }
    initLanguageSelector();
    // initialize languageSelector ------------------

    /**
     * initialize languageSelector for Small Screen
     */
    function initLanguageSelectorforSmallScreen() {
      var $header = $('#gl_header');
      var $langSelecterS = $header.find('#hd_ut_lang_slct');
      var options = $header.find('#hd_ut_lang_slct option');

      $langSelecterS.change( function() {
        var index = this.selectedIndex;
        location.href = options[index].value;
      });
    }
    initLanguageSelectorforSmallScreen();
    // initialize languageSelector for Small Screen ------------------

  });
})(jQuery);
