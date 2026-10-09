$(function () {
  let scrollY;
  const breakPoint = {
    large: 1100,
    middle: 640,
  };
  const mv = () => {
    const elm = $("[data-sec-bg]");
    elm.each(function () {
      const url = $(this).data("sec-bg");
      $(this).css({ "background-image": "url(" + url + ")" });
    });
  };
  mv();

  //aria-currentの設定
  const makeAriaCurrent = (carouselGroup, carouselTarget, carouselItem) => {
    const setAriaCurrent = () => {
      carouselGroup.querySelectorAll(carouselItem).forEach((item) => {
        if (!item) return;
        item.removeAttribute("aria-current");
      });
      let currentSlideNumber = carouselTarget.getCurrentSlide();
      let currentSlideElement = carouselTarget.getCurrentSlideElement();
      let currentSlide = currentSlideElement.prevObject[currentSlideNumber];
      currentSlide.setAttribute("aria-current", "true");
    };
    setAriaCurrent();
    //ボタンクリックでaria-current位置変更
    const prevButton = carouselGroup.closest(".bxsld_wrapper").querySelector(".bxsld_prev");
    const nextButton = carouselGroup.closest(".bxsld_wrapper").querySelector(".bxsld_next");
    prevButton.addEventListener("click", () => {
      setAriaCurrent();
    });
    nextButton.addEventListener("click", () => {
      setAriaCurrent();
    });
  };

  const accordion = () => {
    const target = $('[data-accordion="trigger"]');
    const carouselInThis = '[data-slider="innerCarousel"]:not(.splide)';
    const carouselInAccordionList = document.querySelectorAll(carouselInThis);
    const sliderList = Array.from({ length: carouselInAccordionList.length }); // destroyできるように、各スライダーを配列の要素として個別に管理するための配列
    carouselInAccordionList.forEach((carousel, index) => {
      carousel.dataset.sliderListNumber = index; // sliderListの項目とhtml要素を紐付けするため、項目のindexをdata属性として設定
    });

    const accordionScroll = (accodionPosition) => {
      const winWidth = $(window).width();
      const glovalNavHeight = $(".c-globalNav").innerHeight();
      const FloatNavHeight = $(".c-floatNav").innerHeight();
      if (winWidth > breakPoint.large) {
        const scrollPosition = accodionPosition - glovalNavHeight - FloatNavHeight;
        $("body,html").animate({ scrollTop: scrollPosition }, 500, "swing");
      } else {
        const scrollPosition = accodionPosition - glovalNavHeight;
        $("body,html").animate({ scrollTop: scrollPosition }, 500, "swing");
      }
    };

    target.click(function () {
      // $(this).next('[data-accordion="inner"]').slideToggle(500);
      $(this).closest('[data-accordion="item"]').children('[data-accordion="inner"]').slideToggle(500);
      $(this).toggleClass("is-active");
      if ($(this).hasClass("is-active")) {
        const accodionPosition = $(this).offset().top;
        accordionScroll(accodionPosition);
      }
      const isClose = $(this).attr("aria-expanded") === "false";
      if (isClose) {
        $(this).attr("aria-expanded", "true");
      } else {
        $(this).attr("aria-expanded", "false");
      }

      // bxsliderはスライドの高さを取得しているため、非表示状態だとレイアウト崩れが起きてしまう
      // なのでアコーディオンを開いたらbxsliderを読み込むようにする
      // const carouselInThisList = $(this).next('[data-accordion="inner"]').find(carouselInThis);
      const carouselInThisList = $(this).parents('[data-accordion="item"]').find(carouselInThis);
      if (carouselInThisList.length > 0) {
        if ($(this).hasClass("is-active")) {
          // アコーディオンを開く場合
          // destroyできるように、各スライダーを配列の要素として個別に管理する
          for (let i = 0; i < carouselInThisList.length; i++) {
            const carousel = $(carouselInThisList[i]);
            const carouselItemLength = carousel.children(".c-carousel__item").length;
            if (carouselItemLength >= 2) {
              sliderList[carousel.data("slider-list-number")] = carousel.bxSlider({
                auto: false,
                pager: true,
                controls: true,
                nextText: "",
                prevText: "",
              });
              //aria-currentの設定
              makeAriaCurrent(
                carouselInThisList[i],
                sliderList[carousel.data("slider-list-number")],
                ".c-carousel__item"
              );
            }
          }
        } else {
          // アコーディオンを閉じる場合
          for (let i = 0; i < carouselInThisList.length; i++) {
            const carousel = carouselInThisList[i];
            if (sliderList[carousel.dataset.sliderListNumber]) {
              sliderList[carousel.dataset.sliderListNumber].destroySlider();
              sliderList[carousel.dataset.sliderListNumber] = null;
            }
          }
        }
      }
    });
  };
  accordion();

  const carousel = () => {
    const target = document.querySelectorAll('[data-slider="carousel"]:not(.splide)');
    const carouselStart = () => {
      for (let i = 0; i < target.length; i++) {
        const itemLength = target[i].querySelectorAll(".c-carousel__item").length;
        if (itemLength >= 2) {
          const bxsliderCarousel = $(target[i]).bxSlider({
            auto: false,
            pager: true,
            controls: true,
            nextText: "",
            prevText: "",
          });
          //aria-currentの設定
          makeAriaCurrent(target[i], bxsliderCarousel, ".c-carousel__item");
        }
      }
    };
    $(document).ready(carouselStart);
  };
  carousel();

  const setSliderItemWidth = (target) => {
    const winWidth = $(window).width();
    const sliderItem = target.children(".c-linkCard__item");
    const sliderViewport = target.parent(".bxsld_viewport");
    const viewportWidth = sliderViewport.innerWidth();
    if (winWidth > breakPoint.middle) {
      sliderItem.css("width", (viewportWidth - 24 * 2) / 3 + "px");
    } else {
      sliderItem.css("width", (viewportWidth * 295) / 343 + "px");
    }
  };
  const setSliderWrapperHeight = (target) => {
    let itemHeightArray = new Array();
    const sliderViewport = target.parent(".bxsld_viewport");
    for (let i = 0; i < target.length; i++) {
      const sliderItem = target[i].children;
      // const sliderViewport = target[i].parent();
      for (let j = 0; j < sliderItem.length; j++) {
        itemHeightArray.push(sliderItem[j].clientHeight);
      }
      elemMaxHeight = Math.max.apply(null, itemHeightArray);
      if (sliderViewport[i] != undefined) {
        sliderViewport[i].style.height = elemMaxHeight + "px";
      }
      itemHeightArray = [];
    }
  };
  const setSliderViewportStyle = (target) => {
    target.parent(".bxsld_viewport").css("overflow", "visible");
  };
  const sliderSetting = {
    auto: false,
    pager: false,
    controls: true,
    nextText: "",
    prevText: "",
    slideMargin: 24,
    minSlides: 1,
    maxSlides: 3,
    moveSlides: 1,
    slideWidth: 411,
    infiniteLoop: false,
  };

  const slider = () => {
    const target = $('[data-slider="slider"]:not(.splide)');

    const config = {
      ...sliderSetting,
      onSliderLoad: function () {
        setSliderViewportStyle(target);
        setSliderItemWidth(target);
        setSliderWrapperHeight(target);
      },
    };

    const sliders = new Array();
    target.each(function (i, slider) {
      sliders[i] = $(slider).bxSlider(config);
      //aria-currentの設定
      makeAriaCurrent(slider, sliders[i], ".c-linkCard__item");
    });

    const reloadslider = () => {
      $.each(sliders, function (i, slider) {
        slider.reloadSlider(config);
        //aria-currentの設定
        makeAriaCurrent(slider, sliders[i], ".c-linkCard__item");
      });
    };

    //   const sliderStart = () => {
    //     sliderTarget = target.bxSlider({
    //       ...sliderSetting,
    //       onSliderLoad: function () {
    //         setSliderViewportStyle(target);
    //         setSliderItemWidth(target);
    //       },
    //     });
    //   };
    //   sliderStart();

    let timer;
    $(window).on("resize", function () {
      if (timer) return;
      timer = setTimeout(function (sliderTarget) {
        timer = 0;
        reloadslider();
      }, 500);
    });
  };
  slider();

  const sliderSp = () => {
    const target = $('[data-slider="sliderSp"]:not(.splide)');
    if (!target.length) return;
    let sliderFlag = false;
    let sliderTarget;

    const sliderSpStart = () => {
      sliderTarget = target.bxSlider({
        ...sliderSetting,
        onSliderLoad: function () {
          setSliderViewportStyle(target);
          setSliderItemWidth(target);
          setSliderWrapperHeight(target);
        },
      });
    };

    const viewWidth = () => {
      const winWidth = $(window).width();
      if (winWidth <= breakPoint.middle && !sliderFlag) {
        sliderSpStart();
        sliderFlag = true;
      } else if (winWidth > breakPoint.middle && sliderFlag) {
        sliderTarget.destroySlider();
        sliderFlag = false;
      }
    };

    viewWidth();
    let timer;
    $(window).on("resize", function () {
      if (timer) return;
      timer = setTimeout(function () {
        timer = 0;
        viewWidth();
      }, 500);
    });
  };
  sliderSp();

  const tab = () => {
    const tabWrapper = document.querySelectorAll("[data-tab-wrapper]");
    if (!tabWrapper.length) {
      return;
    }

    const changeContent = (wrapperElement, button, buttons, contents) => {
      buttons.forEach((item) => {
        item.setAttribute("aria-selected", "false");
      });
      contents.forEach((content) => {
        content.setAttribute("aria-hidden", "true");
      });

      const targetButton = button;
      targetButton.setAttribute("aria-selected", "true");
      const targetContents = wrapperElement.querySelectorAll(
        "[data-tab-content=" + targetButton.getAttribute("data-tab-button") + "]"
      );
      targetContents.forEach((content) => {
        content.setAttribute("aria-hidden", "false");
      });
    };

    tabWrapper.forEach((element) => {
      const buttons = element.querySelectorAll("[data-tab-button]");
      const contents = element.querySelectorAll("[data-tab-content]");
      buttons.forEach((button) => {
        button.addEventListener("click", function () {
          changeContent(element, button, buttons, contents);
        });
      });
    });
  };
  tab();

  const accordionToggle = () => {
    const wrap = document.querySelectorAll("[data-accordion-toggle-group]");
    wrap.forEach((elm) => {
      const targets = elm.querySelectorAll("[data-accordion-toggle-targets]");
      const contents = elm.querySelectorAll("[data-accordion-toggle-contents]");
      targets.forEach((target) => {
        $(target).on("click", () => {
          const dataName = $(target).data("accordion-toggle-targets");
          const content = elm.querySelector("[data-accordion-toggle-contents=" + dataName + "]");
          if ($(target).hasClass("is-open")) {
            $(target).removeClass("is-open");
            $(content).slideUp(350);
          } else {
            targets.forEach((item) => {
              $(item).removeClass("is-open");
            });
            contents.forEach((item) => {
              if (item !== content) {
                $(item).hide();
              }
            });
            $(content).slideDown(350);
            $(target).addClass("is-open");
          }
        });
      });
    });
  };
  accordionToggle();

  const sliderPickup = () => {
    if (!document.querySelector('[data-slider="sliderPickup"]:not(.splide)')) return false;
    let slider;
    const slide = () => {
      const target = document.querySelector('[data-slider="sliderPickup"]:not(.splide)');
      let childElementCount = target.childElementCount;
      if (childElementCount > 1) {
        // 295: スライド一枚の大きさ
        // 24 : スライド同士のアキ（実際のアキはpaddingで反映）
        let slideItemWidth = window.innerWidth < breakPoint.middle ? ((295 + 24) / 375) * window.innerWidth : 0;
        let options = {
          auto: false,
          prevSelector: "[data-slide-prev]",
          nextSelector: "[data-slide-next]",
          slideMargin: 0,
          slideWidth: slideItemWidth,
          pagerSelector: "[data-slide-pager]",
        };
        slider = $(target).bxSlider({
          ...options,
          onSliderLoad: function () {
            $(target).parent(".bxsld_viewport").css("overflow", "visible");
          },
        });
        //aria-currentの設定
        const setAriaCurrent = () => {
          target.querySelectorAll(".c-slider-a__item__wrapper").forEach((item) => {
            item.removeAttribute("aria-current");
          });
          let currentSlideNumber = slider.getCurrentSlide();
          let currentSlideElement = slider.getCurrentSlideElement();
          let currentSlide = currentSlideElement.prevObject[currentSlideNumber];
          currentSlide.setAttribute("aria-current", "true");
        };
        setAriaCurrent();
        //ボタンクリックでaria-current位置変更
        const prevButton = target.closest(".c-slider-a").querySelector(".c-slider-a__prev");
        const nextButton = target.closest(".c-slider-a").querySelector(".c-slider-a__next");
        prevButton.addEventListener("click", () => {
          setAriaCurrent();
        });
        nextButton.addEventListener("click", () => {
          setAriaCurrent();
        });
      } else {
        const arrowButton = document.querySelector(".c-slider-a__controller");
        const pager = document.querySelector(".c-slider-a__pager");
        if (arrowButton) {
          arrowButton.style.display = "none";
        }
        if (pager) {
          pager.style.display = "none";
        }
      }
    };
    slide();

    let isRunning = false;
    window.addEventListener("resize", function () {
      if (!isRunning) {
        isRunning = true;
        window.requestAnimationFrame(function () {
          slider.destroySlider();
          slide();
          isRunning = false;
        });
      }
    });
  };
  sliderPickup();

  const matchHeightFunction = () => {
    $("[data-matchHeight").matchHeight();
  };
  matchHeightFunction();

  const pcOnlyTab = () => {
    const dataButton = "data-pc-only-tab-button";
    const dataContent = "data-pc-only-tab-content";
    const tab = document.querySelectorAll("[data-pc-only-tab]");
    tab.forEach((elm) => {
      const buttons = elm.querySelectorAll("[" + dataButton + "]");
      const contents = elm.querySelectorAll("[" + dataContent + "]");
      buttons.forEach((button) => {
        button.addEventListener("click", () => {
          const value = button.getAttribute(dataButton);
          Array.from(buttons).find((item) => {
            if (item.getAttribute(dataButton) !== value) {
              item.classList.remove("is-active");
            }
          });
          button.classList.add("is-active");
          contents.forEach((content) => {
            if (content.getAttribute(dataContent) === value) {
              content.classList.add("is-active");
            } else {
              content.classList.remove("is-active");
            }
          });
        });
      });
    });
  };
  pcOnlyTab();

  const scrollTableWidth = () => {
    const dataName = "data-table-width";
    const tables = document.querySelectorAll(`[${dataName}]`);
    const defaultWidth = "1360";
    tables.forEach((table) => {
      const value = !table.getAttribute(dataName) ? defaultWidth : table.getAttribute(dataName);
      const range = value < breakPoint.middle ? breakPoint.middle : value;
      table.setAttribute("style", `width: ${range}px`);
    });
  };
  scrollTableWidth();

  const scrollTableWidthSp = () => {
    const dataName = "data-sp-table-width";
    const tables = document.querySelectorAll(`[${dataName}]`);
    const defaultWidth = "1360";
    let isRunning = false;
    let isResize = false;
    const tableFunction = (flag) => {
      tables.forEach((table) => {
        if (flag) {
          const value = !table.getAttribute(dataName) ? defaultWidth : table.getAttribute(dataName);
          const range = value < breakPoint.middle ? breakPoint.middle : value;
          table.setAttribute("style", `width: ${range}px`);
        } else {
          table.removeAttribute("style");
        }
      });
    };
    const resizeFunction = () => {
      if (window.innerWidth < Number(breakPoint.middle + 1) && !isResize) {
        isResize = true;
        tableFunction(true);
      } else if (window.innerWidth > breakPoint.middle && isResize) {
        isResize = false;
        tableFunction(false);
      }
    };
    resizeFunction();
    window.addEventListener("resize", () => {
      if (!isRunning) {
        isRunning = true;
        window.requestAnimationFrame(() => {
          resizeFunction();
          isRunning = false;
        });
      }
    });
  };
  scrollTableWidthSp();

  const sliderArticle = () => {
    if (!document.querySelector('[data-slider="sliderArticle"]:not(.splide)')) return false;
    const slider = document.querySelectorAll('[data-slider="sliderArticle"]:not(.splide)');
    const slideArray = Array(slider.length);
    let isRunning = false;
    const SliderLoadFunction = (target) => {
      if (window.innerWidth > breakPoint.middle) {
        const parentDOM = target.parentNode;
        const prevButton = parentDOM.parentNode.querySelector(".bxsld_prev");
        prevButton.classList.add("is-hidden");
      }
    };
    const SlideAfterFunction = (target, array, index) => {
      if (window.innerWidth > breakPoint.middle) {
        const prevButton = target.parentNode.nextElementSibling.querySelector(".bxsld_prev");
        const nextButton = target.parentNode.nextElementSibling.querySelector(".bxsld_next");
        const currentSlide = array[index].getCurrentSlide();
        const slideCount = array[index].getSlideCount() - 1; //カレントと合わせるためにマイナス1
        if (currentSlide > 0) {
          prevButton.classList.remove("is-hidden");
        } else {
          prevButton.classList.add("is-hidden");
        }
        if (currentSlide === Number(slideCount - 1)) {
          nextButton.classList.add("is-hidden");
        } else {
          nextButton.classList.remove("is-hidden");
        }
      }
    };
    const SetItemWidth = (item) => {
      const winWidth = $(window).width();
      const sliderViewport = $(item).parent(".bxsld_viewport");
      const WrapperWidth = sliderViewport.width();
      const sliderItem = $(item).children("div");
      if (winWidth > breakPoint.middle) {
        sliderItem.css("width", (WrapperWidth - 82) / 2 + "px");
      } else {
        // sliderItem.css("width", (WrapperWidth * 295) / 343 + "px");
        sliderItem.css("width", WrapperWidth - 50 + "px");
      }
    };
    const setItemWrapperHeight = (item) => {
      let itemHeightArray = new Array();
      const sliderViewport = $(item).parent(".bxsld_viewport");
      for (let i = 0; i < $(item).length; i++) {
        const sliderItem = $(item)[i].children;
        for (let j = 0; j < sliderItem.length; j++) {
          itemHeightArray.push(sliderItem[j].clientHeight);
        }
        elemMaxHeight = Math.max.apply(null, itemHeightArray);
        if (sliderViewport[i] != undefined) {
          sliderViewport[i].style.height = elemMaxHeight + "px";
        }
        itemHeightArray = [];
      }
    };
    const slideFunction = (reload) => {
      let options = {
        slideMargin: window.innerWidth < Number(breakPoint.middle + 1) ? 32 : 25,
        minSlides: window.innerWidth < Number(breakPoint.middle + 1) ? 1 : 2,
        // slideWidth: window.innerWidth < Number(breakPoint.middle + 1) ? window.innerWidth - 82 : window.innerWidth,
        maxSlides: 2,
        moveSlides: 1,
        shrinkItems: true,
        pager: false,
        infiniteLoop: false,
      };
      if (reload) {
        for (let i = 0; i < slideArray.length; i++) {
          const item = slider[i];
          slideArray[i].reloadSlider({
            ...options,
            onSliderLoad: () => {
              SliderLoadFunction(item);
              SetItemWidth(item);
              setItemWrapperHeight(item);
            },
            onSlideAfter: () => {
              SlideAfterFunction(item, slideArray, i);
            },
          });
          if (slideArray[i].getSlideCount() < 3 && window.innerWidth > breakPoint.middle) {
            item.parentNode.nextElementSibling.classList.add("is-hidden");
          }
        }
      } else {
        for (let i = 0; i < slider.length; i++) {
          const item = slider[i];
          slideArray[i] = $(item).bxSlider({
            ...options,
            onSliderLoad: () => {
              SliderLoadFunction(item);
              SetItemWidth(item);
              setItemWrapperHeight(item);
            },
            onSlideAfter: () => {
              SlideAfterFunction(item, slideArray, i);
            },
          });
          //aria-currentの設定
          makeAriaCurrent(item, slideArray[i], ".c-article__slide__item");
        }
      }
    };
    slideFunction(false);

    window.addEventListener("resize", () => {
      if (!isRunning) {
        isRunning = true;

        window.requestAnimationFrame(() => {
          slideFunction(true);
          isRunning = false;
        });
      }
    });
  };
  sliderArticle();

  // c-globalNavのメニュー内でフォーカスがメニュー外のコンテンツにあたらないようにする
  const globalMenuFocus = () => {
    const links = document.querySelectorAll('[data-globalNav="content"] a');
    const globalNavButton = document.querySelector('[data-globalNav="fadeInButton"]');
    const lastlink = links[links.length - 1];
    // globalNavButtonとlastlinkが存在するかどうかをチェック
    if (globalNavButton && lastlink) {
      const isPC = globalNavButton.offsetParent === null;
      // PCではない場合のみイベントリスナーを追加
      if (!isPC) {
        lastlink.addEventListener("keydown", function (event) {
          if (event.key === "Tab" && !event.shiftKey) {
            event.preventDefault();
            globalNavButton.focus();
          }
        });
      }
    }
  };
  globalMenuFocus();

  const releaseSlider = () => {
    if (!document.getElementById("sliderPro")) return false;
    let sliderImg = $("#sliderPro .sp-slide").length;
    let sliderElement = document.getElementById("sliderPro");
    if (sliderImg === 1) {
      $(sliderElement).sliderPro({
        width: 960,
        height: 480,
        imageScaleMode: "contain",
        autoplayOnHover: "none",
        touchSwipe: false,
        arrows: false,
        buttons: false,
        fadeCaption: false,
      });
    } else {
      if (sliderImg === 2) {
        let slider = $("#sliderPro .sp-slides");
        $(slider).addClass("customize-slides");
        let spSlide = $(slider)
          .html()
          .replace(/sp-slide/g, "sp-slide dSlide");
        $(slider).append(spSlide);
      }
      $(sliderElement).sliderPro({
        width: 960,
        height: 480,
        imageScaleMode: "contain",
        autoplayDelay: 5000,
        arrows: true,
        slideDistance: 0,
        slideAnimationDuration: 800,
        fadeCaption: false,
        playVideoAction: "stopAutoplay",
        pauseVideoAction: "startAutoplay",
        endVideoAction: "startAutoplay",
      });
    }
  };
  $(document).ready(releaseSlider);

  const purchasedProductsScrollableTable = () => {
    const ariaLabelMessages = {
      ja: '横スクロール可能なテーブル',
      en: 'Scrollable table',
    };
    const lang = document.documentElement.lang.toLowerCase() || 'ja';
    const targets = document.querySelectorAll('.c-table--purchasedProducts');
    if (!targets.length) return;
    targets.forEach((target)=>{
      const table = target.querySelector('table');
      if(!table) return;
      const observer = new ResizeObserver(entries => {
        for (const entry of entries) {
          const targetWidth = entry.contentRect.width;
          const tableWidth = table.offsetWidth;

          if (tableWidth > targetWidth) {
            target.setAttribute('tabindex', '0');
            target.setAttribute('aria-label', ariaLabelMessages[lang] || ariaLabelMessages['ja']);
          } else {
            target.removeAttribute('tabindex');
            target.removeAttribute('aria-label');
          }
        }
      });
      // target 要素を監視
      observer.observe(target);
    })
  }
  purchasedProductsScrollableTable();
});

window.addEventListener("DOMContentLoaded", function () {
  // カルーセルの左右スライドボタンにaria-labelを付与
  const setSliderAriaLabel = () => {
    const prevSlideButtons = document.querySelectorAll(".bxsld_prev");
    const nextSlideButtons = document.querySelectorAll(".bxsld_next");

    prevSlideButtons.forEach((button) => {
      button.setAttribute("aria-label", "前のスライドへ");
    });

    nextSlideButtons.forEach((button) => {
      button.setAttribute("aria-label", "次のスライドへ");
    });
  };
  setSliderAriaLabel();
});
