;(function($) {
    //===================================== init var
    var $window;
    var $document;
    var $header;

    //global Navigation
    var $globalNaviWrapper;
    var $globalNaviLi;
    var $globalNaviOpenTrigger;
    var $globalNaviSearchArea;
    var $globalNaviBg;
    var $globalNaviConWrapper;
    var $globalNaviConInner;
    var $globalNaviCloseTrigger;
    var $spMenuTrigger;
    var $spMenuContent;

    var naviOpenClassName = 'open';
    var slideDurationPC = 180;
    var fadeDurationPC = 400;
    var slideDurationSP = 400;
    var spViewFlag = false;
    var onLoadFlag = false;
    var globalNaviPadding;
    var currentID = null;

    $(function() {
        $window = $(window);
        $document = $(document);
        $header = $('#gl_header');

        //global Navigation --------------------------------------
        $globalNaviWrapper = $('#gl_nv');
        $globalNaviLi = $globalNaviWrapper.find('ul.gl_nv_lst > li');
        $globalNaviOpenTrigger = $globalNaviLi.find('a.gl_nv_lst_mn');
        $globalNaviSearchArea = $globalNaviLi.filter('.gl_nv_src');
        $globalNaviBg = $globalNaviWrapper.find('div.drop_down_wrp');
        $globalNaviConWrapper = $globalNaviWrapper.find('div.drop_down');
        $globalNaviConInner = $globalNaviConWrapper.children('div.inner');
        $globalNaviCloseTrigger = $globalNaviConInner.find('a.close');
        $spMenuTrigger = $header.find('a.gl_nv_btn');
        $spMenuContent = $header.find('div.gl_nv_s');
        globalNaviPadding = parseInt($globalNaviConWrapper.css('padding-top')) + parseInt($globalNaviConWrapper.css('padding-bottom'));

        //global navi button action
        $globalNaviOpenTrigger.each(function() {
            var $this = $(this);
            var $parent = $this.closest('li');
            var targetID = String($parent.attr('id'));
            var targetNumString = targetID.replace('gl_nv_lst_', '');
            var $targetContent = $globalNaviConWrapper.find('#drop_down_inner_' + targetNumString);
            var $targetTabWrapper = $targetContent.find('div.tab_sct');
            $this.data('id', targetNumString);

            $this.mouseover(function (e) {
                if (!spViewFlag && onLoadFlag) {
                    if ($this.hasClass(naviOpenClassName)) {
                        //close
                        closeGlobalNavi();
                    } else {
                        //open

                        //init
                        resetGlobalNavi();
                        currentID = $this.data('id');

                        $targetContent.css({
                            display: 'block',
                        });

                        $this.addClass(naviOpenClassName);
                        $globalNaviConWrapper.addClass(naviOpenClassName);

                        //document mouseover close
                        $document.mouseover(closeGlobalNavi);

                        //tab reset
                        if ($targetTabWrapper.size() > 0) {
                            var $targetTabTriggerLi = $targetTabWrapper.find('ul.tab_ttl > li');
                            var $targetTabContent = $targetTabWrapper.find('div.tab_dtl');
                            var tabActiveClassName = 'act';

                            $targetTabTriggerLi.removeClass(tabActiveClassName);
                            $targetTabContent.removeClass(tabActiveClassName);
                            $targetTabTriggerLi.eq(0).addClass(tabActiveClassName);
                            $targetTabContent.eq(0).addClass(tabActiveClassName);
                        }

                        //animate
                        var contentHeight = $targetContent.outerHeight() + globalNaviPadding;
                        //alert('contentHeight: ' + contentHeight);
                        $globalNaviBg.addClass(naviOpenClassName);
                        $globalNaviBg.css('height', contentHeight + 'px');
                        $targetContent.addClass(naviOpenClassName)
                        $window.resize();
                    }
                    e.preventDefault();
                }
            });
        });

        //global navi mouseout
    $('.gl_hd, #gl_nv, .gl_nv_src, .drop_down, #contents').mouseover(function(){
        $('a.gl_nv_lst_mn').removeClass(naviOpenClassName);
        $('.drop_down_wrp').removeClass(naviOpenClassName);
        $('.drop_down').removeClass(naviOpenClassName);
        $globalNaviBg.css('height','0');
    });
    $(' #gl_nv li, .drop_down .inner').mouseover(function (event){
        event.stopPropagation();
    });

        //global navi close button action
        $globalNaviCloseTrigger.mousedown(function (e) {
            closeGlobalNavi();
            e.preventDefault();
            return false;
        });

        //SP menu button action
        $spMenuTrigger.mousedown(function (e) {
            var $this = $(this);
            if ($this.hasClass(naviOpenClassName)) {
                $this.removeClass(naviOpenClassName);
            } else {
                $this.addClass(naviOpenClassName);
            }
            //animate
            $spMenuContent.slideToggle(slideDurationSP, function(){
                if ($this.hasClass(naviOpenClassName)) {
                    $spMenuContent.addClass(naviOpenClassName);
                } else {
                    $spMenuContent.removeClass(naviOpenClassName);
                }
            });

            e.preventDefault();
            return false;
        });

        //global navi area stopPropagation
        $globalNaviWrapper.mouseover(function(e) {
            e.stopPropagation();
            //return false;
        });

        //window load resize action
        $window.on('load resize', function(e){
            if ($spMenuTrigger.css('display') === 'none') {
                //pc
                if (spViewFlag) {
                    spViewFlag = false;
                    closeGlobalNavi();
                    $spMenuContent.css('display', 'block');
                } else {
                    //search area reset
                    var $searchMiddleArea = $globalNaviSearchArea.find('div.dsp_middle');
                    var $searchOpenTrigger = $searchMiddleArea.find('a.gl_nv_lst_mn');
                    if ($searchMiddleArea.css('display') === 'none' && $searchOpenTrigger.hasClass(naviOpenClassName)) {
                        closeGlobalNavi();
                    }
                    //dropdown resize
                    if ($globalNaviConWrapper.hasClass(naviOpenClassName)) {
                        var $targetContent = $globalNaviConWrapper.find('#drop_down_inner_' + currentID);
                        var contentHeight = $targetContent.outerHeight() + globalNaviPadding;
                        $globalNaviBg.css('height', contentHeight + 'px');
                    }
                }
            } else {
                //sp
                if (!spViewFlag) {
                    spViewFlag = true;
                    closeGlobalNavi();
                    $spMenuContent.css('display', 'none').removeClass(naviOpenClassName);
                    $spMenuTrigger.removeClass(naviOpenClassName);
                }
            }

            if ( e.type === 'load' ) {
                $globalNaviBg.css('height', 0);
                onLoadFlag = true;
            }

        }); // $window.on close

        /**
         * closeGlobalNavi
         */
        function closeGlobalNavi() {
            $document.unbind('mouseover', closeGlobalNavi);
            $globalNaviConWrapper.removeClass(naviOpenClassName);
            $globalNaviBg.removeClass(naviOpenClassName);
            $globalNaviBg.css('height', 0);
            currentID = null;
            resetGlobalNavi();
        }

        /**
         * resetGlobalNavi
         */
        function resetGlobalNavi() {
            $globalNaviOpenTrigger.removeClass(naviOpenClassName);
            $globalNaviConInner.css('display', 'none');
        }

        //tab change --------------------------------------
        var $tabWrapper = $globalNaviWrapper.find('div.tabGlobalNavi');

        $tabWrapper.each(function() {
            var $tabWrap = $(this);
            var $tabUl = $tabWrap.find('ul.tab_ttl');
            var $tabTriggerLi = $tabUl.find('li');
            var $tabContent = $tabWrap.find('div.tab_dtl');
            var $tabParentInner = $tabWrap.closest('div.inner');
            var tabActiveClassName = 'act';

            $tabUl.css('display', 'block');

            $tabTriggerLi.eq(0).addClass(tabActiveClassName);
            $tabContent.eq(0).addClass(tabActiveClassName);

            $tabTriggerLi.each(function(index) {
                var $li = $(this);
                var $a = $li.children('a');

                $a.data('tabIndex', index);

                $a.mouseover(function (e) {
                    var $trigger = $(this);
                    var thisIndex = $trigger.data('tabIndex');
                    $tabTriggerLi.removeClass(tabActiveClassName);
                    $tabContent.removeClass(tabActiveClassName);
                    $trigger.parent('li').addClass(tabActiveClassName);
                    $tabContent.eq(thisIndex).addClass(tabActiveClassName);

                    //wrapper height change
                    $globalNaviConWrapper.addClass(naviOpenClassName);
                    var contentHeight = $tabParentInner.outerHeight() + globalNaviPadding;
                    $globalNaviBg.addClass(naviOpenClassName);
                    $globalNaviBg.animate({ height: contentHeight }, slideDurationPC, 'linear');
                    //for align height tab
                    $window.resize();

                    e.preventDefault();
                    return false;
                });
            });
        });

    });
})(jQuery);
