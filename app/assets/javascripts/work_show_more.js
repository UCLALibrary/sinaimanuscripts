// Show More / Show Less toggle for work Table of Contents entries
(function() {
  function initWorkShowMore() {
    var buttons = document.querySelectorAll('.work-show-more--sinai');
    buttons.forEach(function(btn) {
      btn.addEventListener('click', function() {
        var container = btn.closest('.work-toc--sinai');
        if (!container) return;

        var hiddenEntries = container.querySelectorAll('.work-toc-entry--hidden--sinai');
        var isExpanded = btn.getAttribute('data-expanded') === 'true';

        if (isExpanded) {
          // Collapse: hide entries beyond the first 3
          var allEntries = container.querySelectorAll('.work-toc-entry--sinai');
          allEntries.forEach(function(entry, i) {
            if (i >= 3) {
              entry.classList.add('work-toc-entry--hidden--sinai');
            }
          });
          btn.textContent = 'Show More';
          btn.setAttribute('data-expanded', 'false');
        } else {
          // Expand: show all hidden entries
          hiddenEntries.forEach(function(entry) {
            entry.classList.remove('work-toc-entry--hidden--sinai');
          });
          btn.textContent = 'Show Less';
          btn.setAttribute('data-expanded', 'true');
        }
      });
    });
  }

  // Support both Turbolinks and standard page load
  document.addEventListener('turbolinks:load', initWorkShowMore);
  document.addEventListener('DOMContentLoaded', initWorkShowMore);
})();
