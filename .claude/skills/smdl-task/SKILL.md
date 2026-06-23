---
name: smdl-task
description: >-
  Implement or adjust an SMDL (Sinai Manuscripts Digital Library) frontend
  ticket — anything that maps Dawn's JIRA field notation onto the manuscript
  item page. Use whenever the user references an SMDL-* or NOP-* ticket, asks to
  add/change/move a metadata field on a tab (Overview, Codicology, Contents,
  History, Decoration, Keywords, References, Undertexts, Guest/Para content),
  decode Dawn's `[field]` / `.field` / `from each` / `where type.id=` notation,
  or wire a Solr/JSON field through to the Blacklight show page. Loads the SMDL
  data model, the controller→YAML→presenter→view pipeline, the team conventions,
  and a local verification routine.
---

# /smdl-task — Implement an SMDL frontend ticket

This skill turns a ticket written in **Dawn Childress's field notation** into the
correct edits across the Blacklight → Solr rendering pipeline, following the
conventions established on this project. Work through the steps in order.

> **Authoritative reference:** `code_docs/SMDL_FIELD_REFERENCE.md` is the
> source of truth (the "Rosetta Stone" mapping notation ↔ JSON ↔ Solr ↔ code).
> This skill is the *workflow*; the reference is the *lookup table*. When they
> disagree, the reference wins — and update this skill.

---

## Step 1 — Orient

Before touching code, load the mental model:

1. **Read `code_docs/SMDL_FIELD_REFERENCE.md`** in full. It contains the notation
   system, the Overview field map, the data-model hierarchy, the reusable
   sub-objects, and the Solr prefix/suffix tables.
2. For **design rationale or edge cases** (punctuation rules, conditional logic,
   why a sub-object is templated the way it is), consult the onboarding meeting
   transcript: `code_docs/onboarding/onboarding_transcript.txt` (UCLA + Nopio,
   Mar 6 2026 — Dawn walks through the notation and sample data live).
3. For the **exact shape of a field**, read the matching JSON Schema in
   `solr/sinaiportal_data/_documentation/schemas/`:
   - `ms_obj.schema.json` — manuscript object (top level)
   - `layer.schema.json` — inscribed layer (overtext / undertext / guest)
   - `text_unit.schema.json` — discrete texts / work witnesses
   - `work.schema.json`, `agent.schema.json` — referenced works & people
4. To see real values, browse the source JSON in
   `solr/sinaiportal_data/{ms_objs,layers,text_units,works,agents}/*.json`.

---

## Step 2 — Decode the ticket notation

Dawn's tickets describe extraction declaratively. Translate each token:

| Notation | Meaning |
|---|---|
| `Field` (plain) | render with this label |
| `[field]` (square brackets) | render the value but **suppress the label** |
| `.field` | direct child property |
| `..field` | deep descendant — anywhere below in the tree |
| `from each .X.Y.Z` | iterate over the array at that path, emit one block per element |
| `where type.id=X` | filter array elements by `type.id` (e.g. `assoc_date where type.id=origin`) |
| `where event.id=X` | filter by `event.id` (note: `assoc_place` uses **`event`**, not `type`) |
| `where role.id=X` | filter by `role.id` (e.g. `assoc_name where role.id=author`) |
| `\|` | pipe separator between multiple values |
| `;` | conditional separator (e.g. between date and place — only shown when both present) |
| `[label](url)` | render as a hyperlink |
| green text / parentheticals | conditional / "only if present" logic |
| `solr:` prefix | value comes from a **flattened Solr field**, not the JSON blob |

**Reusable sub-objects** — defined once, referenced across many tickets. They
appear at multiple levels (ms_obj, layer, text_unit) with identical structure,
so they map to **shared view partials**:

| Sub-object | JSON array | Filter key | Holds |
|---|---|---|---|
| Paracontent | `para[]` | `type.id` | colophons, inscriptions, guest text (locus, lang, script, as_written, translation) |
| Associated date | `assoc_date[]` | `type.id` | ISO date ranges (e.g. `type.id=origin`) |
| Associated place | `assoc_place[]` | `event.id` | places + `as_written` (filtered by event, e.g. origin) |
| Associated name | `assoc_name[]` | `role.id` | person/entity ref + role |

**Data-model hierarchy:** `ms_obj` → `part` → `layer` (state =
overtext / undertext / guest) → `text_unit`.

---

## Step 3 — Locate the target (tab → files)

Decide which tab the ticket touches, then this is the file set. The view loops
over the presenter, which loads the YAML in declaration order — so **YAML order =
display order**.

| Tab / section | YAML config (`config/metadata-sinai/`) | Presenter (`app/presenters/sinai/`) → method | View partial (`app/views/catalog/work_record--sinai/`) |
|---|---|---|---|
| Overview | `overview_metadata.yml` | `overview_metadata_presenter.rb` → `overview_terms` | `_item_overview_metadata.html.erb` |
| Codicology | `codicology_metadata.yml` | `codicology_metadata_presenter.rb` → `codicology_terms` | `_codicology_metadata.html.erb` |
| Contents | `contents_metadata.yml` | `contents_metadata_presenter.rb` → `contents_terms` | `_content_metadata.html.erb` |
| Contents (works) | `contents_works_metadata.yml` | `contents_works_metadata_presenter.rb` → `contents_terms` | `_content_work_metadata.html.erb` |
| History | `history_metadata.yml` | `history_metadata_presenter.rb` → `history_terms` | `_history_metadata.html.erb` |
| Decoration | `decoration_metadata.yml` | `decoration_metadata_presenter.rb` → `decoration_terms` | `_decorations_metadata.html.erb` |
| Keywords | `keywords_metadata.yml` | `keywords_metadata_presenter.rb` → `keywords_terms` | `_keyword_metadata.html.erb` |
| References | `references_metadata.yml` | `references_metadata_presenter.rb` → `references_terms` | `_references_and_bibliography_metadata.html.erb` |
| Undertexts / Guest / Related / Notes | (JSON-blob driven, no YAML) | — | `_undertexts_metadata.html.erb`, `_paracontents_metadata.html.erb`, `_related_manuscripts_metadata.html.erb`, `_notes_on_manuscript_metadata.html.erb` |

Tab visibility & ordering: `_tab_navigation.html.erb`. All presenters inherit
`app/presenters/base_metadata_presenter.rb`, which loads the YAML and re-sorts
fields into YAML order.

---

## Step 4 — Implement

First identify which of the **two render paths** applies:

### Path A — Solr field (flattened, `solr:` or a `_tesim`/`_ssim`/… field)
This is the common case and is mostly config. Touch files in this order:

1. **`app/controllers/catalog_controller.rb`** — register the field:
   ```ruby
   config.add_show_field 'binding_material_tesim', label: 'Binding Material'
   # add a facet too only if the ticket asks for filtering:
   config.add_facet_field 'binding_material_ssim', sort: 'index', label: 'Binding Material'
   ```
   Useful show-field options: `break_options: {}` (join values with `<br>`
   instead of the default `&nbsp;|&nbsp;`), `separator_options: {}` (return the
   array for a custom loop), `auto_link: true` (linkify URLs),
   `link_to_facet: 'facet_field'` (each value links to its facet search),
   `limit: N`. These flow through `config/initializers/blacklight.rb` +
   `app/processors/{auto_link,custom_join}.rb`.
2. **`config/metadata-sinai/<tab>_metadata.yml`** — add `field_name: 'Label'`.
   **Position in the file = position on the page.**
3. **Presenter** — usually **no change**; only edit if the tab needs custom
   logic beyond the YAML-driven loop.
4. **View partial** — usually **no change** for tabs that loop over the presenter
   (e.g. `_codicology_metadata.html.erb`). Edit only when the field needs bespoke
   markup (custom link, conditional layout — see the `overtext_manuscript_ssm`
   handling in `_history_metadata.html.erb`).

### Path B — JSON blob (nested / reusable sub-objects)
Nested structures (paracontent, assoc_date/place/name, parts, layers, bib) are
read directly from the `manuscript_json_ts` blob and rendered with custom view
logic — **not** via the YAML/presenter loop. Edit the relevant view partial,
parse the JSON path the ticket names, and apply the notation's filter
(`where type.id=…`) and separators (`\|`, `;`). Reuse the existing sub-object
partial when one exists rather than re-parsing inline.

### Solr field conventions (for picking/reading field names)
- **Suffixes:** `_tesim` text multi (full-text searchable) · `_tesi` text single ·
  `_ssim` string multi (facets) · `_ssi` string single · `_ssm` string stored
  (not indexed) · `_isim` integer multi (range facets).
- **Layer-type prefixes:** `ot_` overtext · `para_` paracontent/guest ·
  `uto_` undertext objects · (no prefix) ms_obj level.

### Worked example — `ot_language_ssim` ("Languages") on Overview
1. Controller: `config.add_show_field 'ot_language_ssim', label: 'Languages'`
   (+ `add_facet_field` if filterable).
2. `overview_metadata.yml`: `ot_language_ssim: 'Languages'` (placed where it
   should appear in the list).
3. `_item_overview_metadata.html.erb` renders it via
   `Sinai::OverviewMetadataPresenter.new(document: doc_presenter).overview_terms`
   and `doc_presenter.field_value …`. With `link_to_facet` each value links to
   its facet search.

---

## Step 5 — Conventions (project rules)

- **Never delete commented-out code.** It may be another developer's WIP. Leave
  it in place during feature work. (Project feedback rule.)
- **Match the surrounding view idiom** — copy the existing block's class names
  (`overview-dl__row--sinai`, `metadata-block--sinai`, …) and structure rather
  than inventing markup.
- **Dawn Childress is the domain authority and reviewer** for SMDL frontend
  work. When the ticket notation is ambiguous, decode it against the reference
  and the schemas first; surface a specific question rather than guessing.
- Keep the change small and consistent — SMDL tickets typically touch only
  3–5 files (controller, YAML, sometimes presenter/view, plus a spec).

---

## Step 6 — Verify

1. **Spec:** add or adjust a view spec under
   `spec/views/catalog/work_record_sinai/` (existing examples:
   `item_overview_metadata_spec.rb`, `items_metadata_spec.rb`,
   `parts_metadata_spec.rb`). Run:
   ```bash
   bundle exec rspec spec/views/catalog/work_record_sinai/<file>_spec.rb
   ```
   (Full suite needs `solr_test` on port 8985.)
2. **Lint:**
   ```bash
   bundle exec rubocop
   bundle exec erb_lint --lint-all
   ```
3. **Run the app and look at it** — config changes (controller/YAML) require a
   Rails restart to load:
   ```bash
   docker-compose up
   ```
   App: `http://localhost:3004` · Solr: `http://localhost:8983`. Open a
   manuscript that has data for your field and confirm it renders on the right
   tab, in the right order, with the right label/links. Use `SINAI_ID_BYPASS=true`
   to skip auth. Drive the page with the Playwright MCP tools to click into the
   tab and screenshot the result if a visual check helps.
4. Confirm the field appears (or is correctly hidden when empty) and that the
   separators/links match what the ticket's notation specified.
