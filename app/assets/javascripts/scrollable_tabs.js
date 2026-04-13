// Scrollable tab navigation for detail pages
(function() {
  function initScrollableTabs() {
    var tabList = document.querySelector('.scrollable-tabs__list');
    if (!tabList) return;

    var tabs = tabList.querySelectorAll('.scrollable-tabs__tab');
    var panels = document.querySelectorAll('.tab-panel--sinai');
    var leftArrow = document.querySelector('.scrollable-tabs__arrow--left');
    var rightArrow = document.querySelector('.scrollable-tabs__arrow--right');

    // Check if a tab is clipped by the scroll container edges
    function isTabClipped(tab) {
      var listRect = tabList.getBoundingClientRect();
      var tabRect = tab.getBoundingClientRect();
      var tolerance = 2;
      return tabRect.left < listRect.left - tolerance || tabRect.right > listRect.right + tolerance;
    }

    // Tab click handler
    tabs.forEach(function(tab) {
      tab.addEventListener('click', function() {
        if (isTabClipped(tab)) {
          // Partially hidden — just scroll to reveal, don't activate
          scrollToRevealTab(tab);
          return;
        }

        // Fully visible — activate
        activateTab(tab);
      });
    });

    function activateTab(tab) {
      tabs.forEach(function(t) {
        t.classList.remove('scrollable-tabs__tab--active');
        t.setAttribute('aria-selected', 'false');
      });
      panels.forEach(function(p) {
        p.classList.remove('tab-panel--active');
      });

      tab.classList.add('scrollable-tabs__tab--active');
      tab.setAttribute('aria-selected', 'true');
      var panelId = tab.getAttribute('aria-controls');
      var panel = document.getElementById(panelId);
      if (panel) {
        panel.classList.add('tab-panel--active');
      }

      // Scroll toward hidden tabs if this tab is near that edge.
      // Determine which half of the visible area the tab center sits in
      // to decide direction — this prevents scrolling the wrong way.
      var listRect = tabList.getBoundingClientRect();
      var tabRect = tab.getBoundingClientRect();
      var tabsArray = Array.prototype.slice.call(tabs);
      var idx = tabsArray.indexOf(tab);
      var revealExtra = 150;
      var listCenter = (listRect.left + listRect.right) / 2;
      var tabCenter = (tabRect.left + tabRect.right) / 2;

      var nearRight = (listRect.right - tabRect.right) < 80;
      var nearLeft = (tabRect.left - listRect.left) < 80;
      var hasClippedRight = tabsArray.slice(idx + 1).some(function(t) { return isTabClipped(t); });
      var hasClippedLeft = tabsArray.slice(0, idx).some(function(t) { return isTabClipped(t); });

      if (nearRight && hasClippedRight && tabCenter >= listCenter) {
        tabList.scrollBy({ left: revealExtra, behavior: 'smooth' });
      } else if (nearLeft && hasClippedLeft && tabCenter < listCenter) {
        tabList.scrollBy({ left: -revealExtra, behavior: 'smooth' });
      }
    }

    function scrollToRevealTab(tab) {
      var listRect = tabList.getBoundingClientRect();
      var tabRect = tab.getBoundingClientRect();
      var scrollLeft = tabList.scrollLeft;
      var revealExtra = 150;

      if (tabRect.left < listRect.left) {
        tabList.scrollTo({
          left: scrollLeft - (listRect.left - tabRect.left) - revealExtra,
          behavior: 'smooth'
        });
      } else if (tabRect.right > listRect.right) {
        tabList.scrollTo({
          left: scrollLeft + (tabRect.right - listRect.right) + revealExtra,
          behavior: 'smooth'
        });
      }
    }

    // Scroll arrows — use class toggle so CSS doesn't conflict
    var HIDDEN_CLASS = 'scrollable-tabs__arrow--hidden';

    function updateArrows() {
      if (!leftArrow || !rightArrow) return;
      var maxScroll = tabList.scrollWidth - tabList.clientWidth;

      if (tabList.scrollLeft > 1) {
        leftArrow.classList.remove(HIDDEN_CLASS);
      } else {
        leftArrow.classList.add(HIDDEN_CLASS);
      }

      if (maxScroll > 0 && tabList.scrollLeft < maxScroll - 1) {
        rightArrow.classList.remove(HIDDEN_CLASS);
      } else {
        rightArrow.classList.add(HIDDEN_CLASS);
      }
    }

    if (leftArrow && rightArrow) {
      leftArrow.addEventListener('click', function() {
        tabList.scrollBy({ left: -200, behavior: 'smooth' });
      });
      rightArrow.addEventListener('click', function() {
        tabList.scrollBy({ left: 200, behavior: 'smooth' });
      });
      tabList.addEventListener('scroll', updateArrows);
      window.addEventListener('resize', updateArrows);
      // Initial check
      updateArrows();
    }
  }

  document.addEventListener('DOMContentLoaded', initScrollableTabs);
  document.addEventListener('turbolinks:load', initScrollableTabs);
})();
