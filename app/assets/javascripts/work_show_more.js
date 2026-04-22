// Show More / Show Less toggle for work Table of Contents entries
(function() {
  document.addEventListener('click', function(e) {
    var btn = e.target.closest('.work-show-more--sinai');
    if (!btn) return;

    var container = btn.closest('.work-toc--sinai');
    if (!container) return;

    var isExpanded = container.classList.toggle('work-toc--expanded--sinai');
    btn.textContent = isExpanded ? 'Show Less' : 'Show More';
  });
})();
