// Right-rail sticky navigation behaviour.
//
// The nav HTML is rendered server-side. This script only:
//   1. Highlights the active nav link as the user scrolls (scroll-spy).
//   2. Smooth-scrolls when a nav link is clicked.
//   3. Shows/hides the Examine-manuscript card based on whether the inline
//      Mirador iframe is in the viewport.
//   4. Promotes the inline viewer iframe into a full-screen Examine popup
//      (no second instance, so the viewer keeps its live state).
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
      // On phones the nav is a <details> accordion sitting ABOVE the content.
      // Collapse it first so the smooth-scroll target position is computed
      // against the collapsed layout (avoids overshoot from the height change).
      if (window.matchMedia && window.matchMedia('(max-width: 767px)').matches) {
        var details = link.closest('details.right-rail__nav-details--sinai');
        if (details) details.open = false;
      }
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

  // Examine-manuscript popup.
  //
  // Rather than spinning up a second Mirador instance, we "promote" the single
  // inline viewer iframe into a full-screen overlay via CSS. The iframe element
  // is never reparented and its src is never touched, so the viewer keeps its
  // exact live state (folio, layer, zoom, open panels) when the popup opens.
  // Document-level listeners are bound once; the DOM is re-queried per event so
  // the handlers stay correct across Turbolinks navigations.
  var examineOverlayBound = false;
  var examineLastTrigger = null;

  function getViewerContainer() {
    return document.querySelector('.media-viewer-container');
  }

  function examineIsOpen() {
    var container = getViewerContainer();
    return !!container && container.classList.contains('media-viewer-container--promoted');
  }

  function openExamine(trigger) {
    var container = getViewerContainer();
    if (!container || examineIsOpen()) return;
    examineLastTrigger = trigger || null;
    container.classList.add('media-viewer-container--promoted');
    document.body.classList.add('examine-active');
    var backdrop = document.querySelector('.media-viewer-backdrop--sinai');
    if (backdrop) backdrop.hidden = false;
    var closeBtn = container.querySelector('[data-examine-close]');
    if (closeBtn) closeBtn.focus();
  }

  function closeExamine() {
    var container = getViewerContainer();
    if (!examineIsOpen()) return;
    container.classList.remove('media-viewer-container--promoted');
    document.body.classList.remove('examine-active');
    var backdrop = document.querySelector('.media-viewer-backdrop--sinai');
    if (backdrop) backdrop.hidden = true;
    if (examineLastTrigger && typeof examineLastTrigger.focus === 'function') {
      examineLastTrigger.focus();
    }
    examineLastTrigger = null;
  }

  function setupExamineOverlay() {
    if (examineOverlayBound) return;
    examineOverlayBound = true;

    document.addEventListener('click', function (event) {
      var trigger = event.target.closest('[data-examine-trigger]');
      if (trigger) {
        event.preventDefault();
        openExamine(trigger);
        return;
      }
      if (event.target.closest('[data-examine-close]')) {
        event.preventDefault();
        closeExamine();
      }
    });

    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape' && examineIsOpen()) closeExamine();
    });
  }

  // The Navigation rail's collapsed-on-mobile / open-on-desktop state is handled
  // entirely in CSS: the markup omits `open` (collapsed by default) and a
  // min-width:768px rule forces the tree visible on desktop. No JS needed here.

  function init() {
    if (!document.querySelector('[data-right-rail]')) return;
    activateRail();
    setupTabSwitchObserver();
    setupViewerVisibility();
    setupExamineOverlay();
  }

  document.addEventListener('DOMContentLoaded', init);
  document.addEventListener('turbolinks:load', init);
})();
