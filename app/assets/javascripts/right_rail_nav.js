// Right-rail sticky navigation behaviour.
//
// The nav HTML is rendered server-side. This script only:
//   1. Highlights the active nav link as the user scrolls (scroll-spy).
//   2. Smooth-scrolls when a nav link is clicked.
//   3. Shows/hides the Examine-manuscript card based on whether the inline
//      Mirador iframe is in the viewport.
//   4. Promotes the inline viewer iframe into a full-screen Examine popup
//      (no second instance, so the viewer keeps its live state).
//   5. Expands a truncated work list in the nav tree, on click or when
//      scroll-spy lands on one of its hidden rows (NOP-182).
(function () {
  var scrollHandler = null;
  var moreToggleBound = false;

  // Reveals a truncated work list (NOP-182) and syncs its toggle label.
  // No-op for links outside such a group.
  function expandMoreGroup(group) {
    if (!group || group.classList.contains('is-expanded')) return;
    group.classList.add('is-expanded');
    var btn = group.querySelector('.right-rail__nav-more--sinai');
    if (btn) btn.textContent = 'Show Less';
  }
  // How far below the viewport top a heading must cross to count as "current".
  // NOP-166: this must clear the sticky title+tabs header, so a section is marked
  // active once its heading passes just below the pinned block (header height +
  // 16px). Measured live so it stays correct when a long title wraps. Falls back
  // to 120 if the header isn't present.
  function getActiveOffset() {
    var header = document.querySelector('.item-page__sticky-header--sinai');
    return (header ? header.offsetHeight : 120) + 16;
  }

  function getActiveRail() {
    var activePanel = document.querySelector('.tab-panel--sinai.tab-panel--active');
    if (!activePanel) return null;
    return activePanel.querySelector('[data-right-rail]');
  }

  function collectEntries(rail) {
    if (!rail) return [];
    // Resolve ids WITHIN the rail's own panel. The same section-* ids are emitted
    // in more than one tab panel (e.g. Full Description and Contents both render the
    // parts/items tree), and all panels stay in the DOM (inactive = display:none).
    // document.getElementById would return the first match — a hidden panel's copy
    // at rect top 0 — breaking scroll-spy and click-to-scroll on non-first tabs.
    var scope = rail.closest('.tab-panel--sinai') || document;
    var links = rail.querySelectorAll('a[data-right-rail-link]');
    var entries = [];
    links.forEach(function (link) {
      var id = link.getAttribute('data-right-rail-link');
      var target = id && scope.querySelector('[id="' + id + '"]');
      if (target) entries.push({ id: id, link: link, target: target });
    });
    return entries;
  }

  // The single choke point for .is-active — scroll-spy, the init run and the
  // post-click update all route through here, as does the synthetic scroll event
  // expand_collapse_all.js fires after a mass expand.
  function setActive(entries, activeId) {
    entries.forEach(function (entry) {
      if (entry.id === activeId) {
        // A truncated work list keeps its overflow rows in the DOM, so scroll-spy
        // can pick one as current. Reveal the group first: otherwise the class
        // lands on a display:none link and the else-branch below has already
        // cleared the previous highlight, leaving the rail with none at all.
        expandMoreGroup(entry.link.closest('[data-rail-nav-more-group]'));
        entry.link.classList.add('is-active');
      } else {
        entry.link.classList.remove('is-active');
      }
    });
  }

  // Show More / Show Less for a truncated work list.
  //
  // A document-level delegate bound once, NOT part of setupClickHandling: that
  // re-binds on every activateRail() (DOMContentLoaded, turbolinks:load, and each
  // tab-class mutation), so a toggle there would fire N times and cancel itself.
  function setupNavMoreToggle() {
    if (moreToggleBound) return;
    moreToggleBound = true;
    document.addEventListener('click', function (event) {
      var btn = event.target.closest('.right-rail__nav-more--sinai');
      if (!btn) return;
      var group = btn.closest('[data-rail-nav-more-group]');
      if (!group) return;
      btn.textContent = group.classList.toggle('is-expanded') ? 'Show Less' : 'Show More';
    });
  }

  function computeActiveId(entries) {
    // Active = the last heading whose top edge is at or above the active offset.
    // Falls back to the first heading if none have crossed yet.
    var activeOffset = getActiveOffset();
    var currentId = entries[0] ? entries[0].id : null;
    for (var i = 0; i < entries.length; i++) {
      var top = entries[i].target.getBoundingClientRect().top;
      if (top - activeOffset <= 0) {
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
      // Use the panel-scoped target resolved in collectEntries (not
      // document.getElementById, which can hit a duplicate id in a hidden panel).
      var entry = null;
      for (var i = 0; i < entries.length; i++) {
        if (entries[i].link === link) { entry = entries[i]; break; }
      }
      var target = entry && entry.target;
      if (!target) return;
      event.preventDefault();
      // On phones the nav is a <details> accordion sitting ABOVE the content.
      // Collapse it first so the smooth-scroll target position is computed
      // against the collapsed layout (avoids overshoot from the height change).
      if (window.matchMedia && window.matchMedia('(max-width: 767px)').matches) {
        var details = link.closest('details.right-rail__nav-details--sinai');
        if (details) details.open = false;
      }
      // NOP-177: now that "Collapse all" exists, a nav target is routinely inside
      // a closed <details>, where it isn't rendered and scrollIntoView lands on
      // the closed ancestor instead. Open the whole ancestor chain first — and the
      // target itself when it IS a <details>, since work accordions carry their
      // section-* id on the <details> element (see _item_entry.html.erb). Only
      // main-column <details> are reachable here, so the rail's own Navigation
      // accordion is never touched.
      var disclosure = target.closest('details');
      while (disclosure) {
        disclosure.open = true;
        disclosure = disclosure.parentElement && disclosure.parentElement.closest('details');
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
    setupNavMoreToggle();
    setupViewerVisibility();
    setupExamineOverlay();
  }

  document.addEventListener('DOMContentLoaded', init);
  document.addEventListener('turbolinks:load', init);
})();
