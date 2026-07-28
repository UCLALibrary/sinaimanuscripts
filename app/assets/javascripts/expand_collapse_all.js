// Expand all / Collapse all for the manuscript item page (NOP-177).
//
// One control per tab panel, rendered server-side into that panel's sticky right
// rail (see _right_rail.html.erb and RightRailHelper#panel_has_collapsibles?).
// It flips its own label between "Expand all" and "Collapse all" from the CURRENT
// state of the panel, so it stays honest when the user opens or closes an
// individual row by hand.
//
// What it drives — everything in ONE panel's main column, at every nesting level:
//   * details.work-accordion--sinai  — object accordions (works, rubrics,
//     paracontent, guest layers). Tag-qualified on purpose: the non-collapsible
//     twin <div class="work-accordion--sinai work-accordion--static--sinai">
//     shares the block class and must not be matched.
//   * details.part-expandable--sinai — field rows (Support, Writing, Ink,
//     Item Notes, Editions).
//   * .work-toc--sinai               — the Table of Contents "Show More", which
//     is a class toggle rather than a <details>. Driven by clicking its own
//     button so work_show_more.js stays the single owner of that class and label.
//
// Deliberately NOT touched:
//   * details.right-rail__nav-details--sinai — the rail's own Navigation
//     accordion (desktop CSS force-opens it; mobile uses it as a drawer).
//     Excluded structurally: it lives in the rail column, and every query below
//     is scoped to .tab-panel-grid__main--sinai.
//   * details.overview-json-debug--sinai — the raw JSON debug dump. Excluded by
//     class: it carries none of the selectors above.
(function () {
  var PANEL_SELECTOR = '.tab-panel--sinai';
  var MAIN_SELECTOR = '.tab-panel-grid__main--sinai';
  var CONTROL_SELECTOR = '[data-expand-all-toggle]';
  var LABEL_SELECTOR = '.right-rail__expand-label--sinai';
  var DETAILS_SELECTOR = 'details.work-accordion--sinai, details.part-expandable--sinai';
  var TOC_SELECTOR = '.work-toc--sinai';
  var TOC_BUTTON_SELECTOR = 'button.work-show-more--sinai';
  var TOC_EXPANDED_CLASS = 'work-toc--expanded--sinai';
  var LABEL_EXPAND = 'Expand all';
  var LABEL_COLLAPSE = 'Collapse all';

  var boundPanels = new WeakSet();
  var documentBound = false;
  var syncPending = false;

  // The panel's MAIN column. Never query document-wide: every tab panel stays in
  // the DOM (inactive ones are display:none) and the same section-* ids repeat
  // across panels, so a global query would act on the wrong tab. Scoping here
  // also puts the rail's own Navigation <details> structurally out of reach.
  function mainColumnFor(el) {
    var panel = el.closest(PANEL_SELECTOR);
    return panel ? panel.querySelector(MAIN_SELECTOR) : null;
  }

  // A work with three or fewer ToC entries renders no button and has nothing to
  // expand; such a container must not make the panel look "not fully expanded".
  function tocButton(toc) {
    return toc.querySelector(TOC_BUTTON_SELECTOR);
  }

  function isExpanded(scope) {
    var details = scope.querySelectorAll(DETAILS_SELECTOR);
    for (var i = 0; i < details.length; i++) {
      if (!details[i].open) return false;
    }
    var tocs = scope.querySelectorAll(TOC_SELECTOR);
    for (var j = 0; j < tocs.length; j++) {
      if (tocButton(tocs[j]) && !tocs[j].classList.contains(TOC_EXPANDED_CLASS)) return false;
    }
    return true;
  }

  function setAll(scope, open) {
    // querySelectorAll reaches <details> nested inside a CLOSED <details> too —
    // they are in the DOM, just not rendered — so one flat pass covers every level.
    var details = scope.querySelectorAll(DETAILS_SELECTOR);
    for (var i = 0; i < details.length; i++) {
      details[i].open = open;
    }
    var tocs = scope.querySelectorAll(TOC_SELECTOR);
    for (var j = 0; j < tocs.length; j++) {
      var btn = tocButton(tocs[j]);
      if (!btn) continue;
      // Click rather than duplicate: work_show_more.js owns both the expanded
      // class and the "Show More"/"Show Less" label. Its document-level delegate
      // runs synchronously inside this call, so the state is settled on return.
      if (tocs[j].classList.contains(TOC_EXPANDED_CLASS) !== open) btn.click();
    }
  }

  function syncControl(control) {
    var scope = mainColumnFor(control);
    if (!scope) return;
    var expanded = isExpanded(scope);
    control.setAttribute('data-state', expanded ? 'expanded' : 'collapsed');
    var label = control.querySelector(LABEL_SELECTOR) || control;
    var next = expanded ? LABEL_COLLAPSE : LABEL_EXPAND;
    if (label.textContent !== next) label.textContent = next;
  }

  function syncAll() {
    var controls = document.querySelectorAll(CONTROL_SELECTOR);
    for (var i = 0; i < controls.length; i++) syncControl(controls[i]);
  }

  // A mass expand fires one `toggle` per <details>, and `toggle` is queued rather
  // than dispatched synchronously — so this cannot be suppressed with a flag set
  // around setAll(). Coalesce the flood into a single relabel instead.
  function scheduleSync() {
    if (syncPending) return;
    syncPending = true;
    window.requestAnimationFrame(function () {
      syncPending = false;
      syncAll();
    });
  }

  function onDocumentClick(event) {
    var control = event.target.closest(CONTROL_SELECTOR);
    if (!control) return;
    event.preventDefault();
    var scope = mainColumnFor(control);
    if (!scope) return;

    setAll(scope, !isExpanded(scope));
    // <details>.open and the ToC class are both already updated here (only the
    // `toggle` EVENT is async), so this reads the final state.
    syncControl(control);

    // The rail scroll-spy in right_rail_nav.js only recomputes on scroll, and a
    // mass expand/collapse moves every heading. Nudge it so the highlighted nav
    // entry isn't stale until the user happens to scroll. Its listener is passive
    // and cheap; with no rail on the page this is a no-op.
    window.dispatchEvent(new Event('scroll'));
  }

  function onPanelClick(event) {
    // The ToC "Show More" button is handled by work_show_more.js on a
    // document-level delegate, which runs AFTER this panel-level one (the panel
    // is the closer ancestor). The expanded class hasn't flipped yet, so defer.
    if (event.target.closest(TOC_BUTTON_SELECTOR)) scheduleSync();
  }

  function bindPanel(panel) {
    if (boundPanels.has(panel)) return;
    boundPanels.add(panel);

    // `toggle` does NOT bubble, so a normal delegated listener on the panel would
    // never see it. It DOES traverse the capture phase on the way down, so one
    // capture-phase listener here catches every <details> underneath the panel
    // and keeps working across any DOM churn.
    panel.addEventListener('toggle', scheduleSync, true);
    panel.addEventListener('click', onPanelClick);
  }

  function init() {
    var controls = document.querySelectorAll(CONTROL_SELECTOR);
    if (!controls.length) return;

    // Bound once for the life of the document. Turbolinks replaces <body>, not
    // `document`, so this must NOT be rebound on turbolinks:load.
    if (!documentBound) {
      documentBound = true;
      document.addEventListener('click', onDocumentClick);
    }

    // Per-panel listeners are guarded by a WeakSet, so the DOMContentLoaded +
    // turbolinks:load double-fire on first load binds only once, while the fresh
    // elements a Turbolinks visit installs are correctly treated as new.
    for (var i = 0; i < controls.length; i++) {
      var panel = controls[i].closest(PANEL_SELECTOR);
      if (panel) bindPanel(panel);
    }

    syncAll();
  }

  document.addEventListener('DOMContentLoaded', init);
  document.addEventListener('turbolinks:load', init);
})();
