// Right-rail sticky navigation behaviour.
//
// The nav HTML is rendered server-side. This script only:
//   1. Highlights the active nav link as the user scrolls (scroll-spy).
//   2. Smooth-scrolls when a nav link is clicked.
//   3. Shows/hides the Examine-manuscript card based on whether the inline
//      Mirador iframe is in the viewport.
//   4. Lazy-loads the Examine-manuscript modal iframe on first open.
(function () {
  var scrollHandler = null;
  // How far below the viewport top a heading must cross to count as "current".
  var ACTIVE_OFFSET = 120;

  function getActiveRail() {
    var activePanel = document.querySelector('.tab-panel--sinai.tab-panel--active');
    if (!activePanel) return null;
    return activePanel.querySelector('[data-right-rail]');
  }

  function collectEntries(rail) {
    if (!rail) return [];
    var links = rail.querySelectorAll('a[data-right-rail-link]');
    var entries = [];
    links.forEach(function (link) {
      var id = link.getAttribute('data-right-rail-link');
      var target = id && document.getElementById(id);
      if (target) entries.push({ id: id, link: link, target: target });
    });
    return entries;
  }

  function setActive(entries, activeId) {
    entries.forEach(function (entry) {
      if (entry.id === activeId) {
        entry.link.classList.add('is-active');
      } else {
        entry.link.classList.remove('is-active');
      }
    });
  }

  function computeActiveId(entries) {
    // Active = the last heading whose top edge is at or above ACTIVE_OFFSET.
    // Falls back to the first heading if none have crossed yet.
    var currentId = entries[0] ? entries[0].id : null;
    for (var i = 0; i < entries.length; i++) {
      var top = entries[i].target.getBoundingClientRect().top;
      if (top - ACTIVE_OFFSET <= 0) {
        currentId = entries[i].id;
      } else {
        break;
      }
    }
    return currentId;
  }

  function setupScrollSpy(entries) {
    if (scrollHandler) {
      window.removeEventListener('scroll', scrollHandler);
      scrollHandler = null;
    }
    if (!entries.length) return;

    var ticking = false;
    scrollHandler = function () {
      if (ticking) return;
      ticking = true;
      window.requestAnimationFrame(function () {
        setActive(entries, computeActiveId(entries));
        ticking = false;
      });
    };
    window.addEventListener('scroll', scrollHandler, { passive: true });
    // Run once on init so the right entry is marked from the start.
    setActive(entries, computeActiveId(entries));
  }

  function setupClickHandling(rail, entries) {
    if (!rail) return;
    rail.addEventListener('click', function (event) {
      var link = event.target.closest('a[data-right-rail-link]');
      if (!link) return;
      var id = link.getAttribute('data-right-rail-link');
      var target = document.getElementById(id);
      if (!target) return;
      event.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      if (history.replaceState) {
        history.replaceState(null, '', '#' + id);
      }
      setActive(entries, id);
    });
  }

  function activateRail() {
    var rail = getActiveRail();
    var entries = collectEntries(rail);
    setupClickHandling(rail, entries);
    setupScrollSpy(entries);
  }

  function setupTabSwitchObserver() {
    var panels = document.querySelectorAll('.tab-panel--sinai');
    if (!panels.length) return;
    var observer = new MutationObserver(function (mutations) {
      for (var i = 0; i < mutations.length; i++) {
        if (mutations[i].attributeName === 'class') {
          activateRail();
          return;
        }
      }
    });
    panels.forEach(function (p) {
      observer.observe(p, { attributes: true, attributeFilter: ['class'] });
    });
  }

  function setupViewerVisibility() {
    var iframe = document.getElementById('media-viewer-iframe');
    var cards = document.querySelectorAll('[data-right-rail-viewer]');
    if (!cards.length) return;
    if (!iframe) {
      cards.forEach(function (c) { c.hidden = true; });
      return;
    }
    if (!('IntersectionObserver' in window)) {
      cards.forEach(function (c) { c.hidden = false; });
      return;
    }
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        cards.forEach(function (card) {
          card.hidden = entry.isIntersecting;
        });
      });
    }, { threshold: 0.05 });
    observer.observe(iframe);
  }

  function setupModalLazyLoad() {
    var modal = document.getElementById('examine-manuscript-modal');
    if (!modal || !window.jQuery) return;
    var iframe = modal.querySelector('[data-examine-manuscript-iframe]');
    if (!iframe) return;
    var src = iframe.getAttribute('data-iframe-src') || '';
    window.jQuery(modal).on('show.bs.modal', function () {
      if (src && iframe.getAttribute('src') !== src) {
        iframe.setAttribute('src', src);
      }
    });
    window.jQuery(modal).on('hidden.bs.modal', function () {
      iframe.setAttribute('src', '');
    });
  }

  function init() {
    if (!document.querySelector('[data-right-rail]')) return;
    activateRail();
    setupTabSwitchObserver();
    setupViewerVisibility();
    setupModalLazyLoad();
  }

  document.addEventListener('DOMContentLoaded', init);
  document.addEventListener('turbolinks:load', init);
})();
