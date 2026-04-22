# SMDL Field Reference Guide

> Rosetta Stone for mapping between Dawn's JIRA ticket notation, the JSON data model, Solr field names, and Rails code locations.

---

## 1. Dawn's Ticket Notation System

Dawn uses a custom notation in JIRA tickets to describe where field values come from and how they should be displayed. This is the key to reading any SMDL ticket.

### Source Indicators

| Notation | Meaning | Example |
|---|---|---|
| `[summary]` | Value from JSON blob, **label not displayed** | Show summary text but no "Summary:" label |
| `Summary` (no brackets) | Value from JSON blob, **label IS displayed** | Show "Summary:" label followed by value |
| `[solr:field_name_ssim]` | Value from a **flattened Solr field**, not the JSON blob | `[solr:repository_ssim]` = use `repository_ssim` from Solr |

### JSON Path Notation

| Notation | Meaning | Example |
|---|---|---|
| `.field` (single dot) | **Direct child** — immediate descendant of current object | `.ot_layer.writing` = `layer.writing` (direct property) |
| `..field` (double dot) | **Deep descendant** — anywhere in the tree below | `..ot_layer..assoc_date.value` = find `assoc_date.value` anywhere under any OT layer |
| `from each .X.Y.Z` | **Iterate** over array, extract sub-properties | `from each .ot_layer.writing.script` = loop through all script entries in all writing objects |
| `where type.id=X` | **Filter** array items by a type/event discriminator | `assoc_date where type.id=origin` = only origin dates |
| `where event.id=X` | Same filter pattern for place associations | `assoc_place where event.id=origin` = only origin places |

### Display Rules

| Notation | Meaning | Example |
|---|---|---|
| Values on same line with `\|` | **Pipe separator** between multiple values | Languages: `Arabic \| Syriac \| Greek` |
| Values on separate lines | **New line** for each value | Multiple origin date/place pairs |
| Semicolon between fields | **Conditional separator** — only shown if both values present | Date `;` Place — no semicolon if only date exists |
| Green text / parenthetical instructions | **Conditional logic** or special rendering rules | `where type.id=origin (for dates)` |
| `[field.label](field.url)` | **Hyperlink** — label as link text, url as href | `[viscodex.label](viscodex.url)` renders a clickable link |
| `[square brackets]` around field name | Field value is shown but **label is hidden** | `[Summary]` shows content without "Summary:" heading |

---

## 2. Overview Section — Field Map

From the SMDL Overview ticket (see `code_docs/onboarding/smdl_overview_screenshot.jpg`):

> "All values are pulled from the JSON blob, unless otherwise noted with `solr:`"

| # | Display Field | Dawn's Notation | JSON Source Path | Current Solr Field | Display Rules |
|---|---|---|---|---|---|
| 1 | **Summary** | `[summary]` | `ms_obj.summary` | `summary_tesim` | No label displayed. Italics. Left-aligned at top of section |
| 2 | **Location** | `[solr:repository_ssim]`, `[solr:collection_ssim]` | N/A (Solr direct) | `repository_ssim`, `collection_ssim` | Two values combined |
| 3 | **Current state** | `[solr:state_ssi]` | `ms_obj.state.label` | `state_ssi` | Single value |
| 4 | **Origin** | `[..ot_layer..assoc_date.value]` ; `[..ot_layer..assoc_place.value]` | `layer.assoc_date[type.id=origin].value` + `layer.assoc_place[event.id=origin].value` | `date_created_tesim`, `place_of_origin_tesim` | Can have multiple date/place pairs on separate lines. Semicolon conditional on both values existing |
| 5 | **Scripts** | `from each .ot_layer.writing.script [.label] [(.writing_system)]` | `layer.writing[].script[].label` + `.writing_system` | `script_tesim`, `writing_system_tesim` | Each entry is a script/writing system pair. Pipe-separated on same line |
| 6 | **Languages** | `[solr:ot_language_ssim]` | N/A (Solr direct) | `ot_language_ssim` | Pipe-separated. Not all values will be present |
| 7 | **Extent** | `[extent]` `[dim]` `[weight]` | `ms_obj.extent`, `ms_obj.dim`, `ms_obj.weight` | `format_extent_tesim` | Pipe separators conditional on adjacent values existing |
| 8 | **Foliation** | `[fol]` | `ms_obj.fol` | `foliation_tesim` | Not always present. Only shown if `note` has `type.id=foliation` |
| 9 | **Collation** | `[coll]` | `ms_obj.coll` | `collation_tesim` | Not always present. If viscodex exists: `[viscodex.label](viscodex.url)` as clickable link. `type.id=manuscript` should be listed first (order TBD). Multiple viscodex entries on separate lines |
| 10 | **Keywords** | `[solr:features_ssim]` `[solr:ot_genre_ssim]` | N/A (Solr direct) | `features_ssim`, `ot_genre_ssim` | From Solr facet fields |

---

## 3. JSON Data Model Hierarchy

The source data lives in `solr/sinaiportal_data/` as separate JSON files per record type. The `feed_ursus` tool (`sinai load`) flattens these into Solr fields during the Docker build. The hierarchy is:

```
ms_obj (Manuscript Object)  ← solr/sinaiportal_data/ms_objs/*.json
│                              Schema: solr/sinaiportal_data/_documentation/schemas/ms_obj.schema.json
│
├── Top-level scalars
│   ├── ark          — unique ARK identifier (e.g., "ark:/21198/z12v3d24")
│   ├── shelfmark    — library classification (e.g., "Sinai Georgian 49")
│   ├── type         — {id, label} e.g., {"id": "manuscript", "label": "Manuscript"}
│   ├── state        — {id, label} e.g., {"id": "codex", "label": "Codex"}
│   ├── reconstruction — boolean
│   ├── summary      — free text description (nullable)
│   ├── extent       — folio count string (e.g., "119 ff.")
│   ├── dim          — dimensions string (e.g., "157 x 135 x 37 mm")
│   ├── weight       — weight string (nullable)
│   ├── fol          — foliation string (nullable)
│   └── coll         — collation formula string (nullable)
│
├── features[]       — [{id, label}] controlled terms (e.g., "Palimpsest", "MSI")
├── note[]           — [{type: {id, label}, value}] filtered by type.id
│                      Types: "foliation", "general", "ornamentation", "binding", etc.
├── bib[]            — bibliography entries
├── viscodex[]       — [{label, url}] links to collation viewer
│
├── part[] (Physical Parts / Production Units)
│   ├── label, summary, locus
│   ├── support[]    — [{id, label}] e.g., "Parchment", "Paper"
│   ├── extent, dim
│   ├── layer[]      — references to separate layer records
│   │   ├── id       — ARK of the layer record
│   │   ├── label    — display label
│   │   ├── type     — {id: "overtext"|"undertext"|"guest", label}
│   │   └── locus    — folio range
│   └── para[]       — [paracontent objects] (see Section 4)
│
├── assoc_date[]     — [associated date objects] (see Section 4)
├── assoc_name[]     — [associated name objects] (see Section 4)
├── assoc_place[]    — [associated place objects] (see Section 4)
└── related_mss[]    — references to related manuscripts


layer (Inscribed Layer)  ← solr/sinaiportal_data/layers/*.json
│                          Schema: solr/sinaiportal_data/_documentation/schemas/layer.schema.json
│
├── ark, label, locus, summary, extent, reconstruction
├── state            — {id: "overtext"|"undertext"|"guest"|"reconstruction", label}
├── writing[]        — handwriting instances
│   ├── script[]     — [{id, label, writing_system}]
│   │                  e.g., {"id": "kufic", "label": "Kufic", "writing_system": "Arabic"}
│   ├── locus
│   └── note[]
├── ink[]            — [{locus, color[], note}]
├── layout[]         — [{locus, columns, lines, dim, note}]
├── text_unit[]      — references to text_unit records [{id (ARK), label, locus}]
├── para[]           — [paracontent objects]
├── assoc_date[], assoc_name[], assoc_place[]
├── note[]           — filtered by type.id
├── features[]
└── parent[]         — ARK references to parent ms_obj


text_unit (Text Unit)  ← solr/sinaiportal_data/text_units/*.json
│                        Schema: solr/sinaiportal_data/_documentation/schemas/text_unit.schema.json
│
├── ark, label, locus, summary, cataloguer
├── work_wit[]       — work witness references (with excerpts, contents, bib)
├── para[]           — [paracontent objects]
├── assoc_date[], assoc_name[], assoc_place[]
├── note[], bib[], features[]
└── parent[]         — ARK references to parent layer
```

### Example: Tracing a Real Manuscript

**Manuscript**: Sinai Georgian 49 (`solr/sinaiportal_data/ms_objs/z12v3d24.json`)

```
ms_obj (z12v3d24)
├── shelfmark: "Sinai Georgian 49"
├── extent: "119 ff."
├── dim: "157 x 135 x 37 mm"
├── state: {id: "codex", label: "Codex"}
├── coll: "Quire 1: 1x8 (8); Quires 2-6: 8x1 (48)..."
├── features: ["Palimpsest", "Multispectral Imaging"]
└── part[0]
    ├── support: ["Parchment"]
    └── layer[]:
        ├── [0] Overtext Layer (ark:/21198/s14k8t) — type: overtext
        ├── [1] Syriac Undertext (ark:/21198/s1tp82) — type: undertext, locus: "f. 16"
        ├── [2] Syriac Undertext (ark:/21198/s1q053) — type: undertext, locus: "ff. 37, 39"
        └── ... (12 layers total)
```

**Layer**: Sinai Greek 930, Undertext (`solr/sinaiportal_data/layers/s1zw6m.json`)

```
layer (s1zw6m)
├── label: "Sinai Greek 930, Undertext (Kufic)"
├── state: {id: "undertext"}
├── writing[0].script[0]: {id: "kufic", label: "Kufic", writing_system: "Arabic"}
├── layout[0]: {columns: "1 columns", lines: "16 lines"}
├── assoc_date[0]: {type.id: "origin", value: "10th or 11th c. CE"}
├── assoc_place[0]: {value: "North Africa", event.id: "origin"}
└── parent: ["ark:/21198/z1b0085j"]
```

---

## 4. Reusable Sub-Objects

These JSON objects appear at multiple levels of the hierarchy. Dawn describes them once in separate JIRA tickets and references them from parent tickets. **We should build matching reusable Rails view partials.**

### Paracontent (`para[]`)

Guest/supplementary text content (colophons, inscriptions, additions, etc.)

```json
{
  "type": {"id": "colophon", "label": "Colophon"},
  "locus": "f. 26r",
  "lang": [{"id": "syriac", "label": "Syriac"}],
  "script": [{"id": "estrangela", "label": "Estrangela", "writing_system": "Syriac"}],
  "label": "Colophon by scribe",
  "as_written": "Original text in manuscript script",
  "translation": ["English translation"],
  "assoc_name": [],
  "assoc_place": [],
  "assoc_date": [],
  "note": []
}
```

**Appears at**: `ms_obj.part[].para[]`, `layer.para[]`, `text_unit.para[]`

### Associated Date (`assoc_date[]`)

```json
{
  "type": {"id": "origin", "label": "Date of Origin"},
  "value": "10th or 11th c. CE",
  "as_written": "...",
  "iso": {"not_before": "0901", "not_after": "1100"},
  "note": ["..."]
}
```

**Filter by**: `type.id` — common values: `"origin"`, `"creation"`

### Associated Place (`assoc_place[]`)

```json
{
  "value": "North Africa",
  "event": {"id": "origin", "label": "Place of Origin"},
  "as_written": "...",
  "note": ["..."]
}
```

**Filter by**: `event.id` — common values: `"origin"`
**Note**: Uses `event` not `type` (unlike assoc_date which uses `type`)

### Associated Name (`assoc_name[]`)

```json
{
  "id": "ark:/21198/...",
  "value": "Name of person",
  "as_written": "Name in original script",
  "role": {"id": "author", "label": "Author"},
  "note": ["..."]
}
```

**Filter by**: `role.id` — common values: `"author"`, `"scribe"`, `"illuminator"`, `"editor"`, `"translator"`

### Writing (`writing[]`)

```json
{
  "script": [
    {"id": "kufic", "label": "Kufic", "writing_system": "Arabic"}
  ],
  "locus": "ff. 1-50",
  "note": ["Late kufi"]
}
```

**Only on**: `layer.writing[]`

---

## 5. Code Pipeline

How data flows from JSON source to rendered HTML:

```
 JSON files in solr/sinaiportal_data/
        │
        ▼
 feed_ursus (Python CLI: `sinai load /data`)
 Flattens nested JSON → individual Solr fields
 Run during: solr/Dockerfile build → solr/load_data.sh
        │
        ▼
 Solr Index (Solrizer field naming)
 _tesim = text, stored, indexed, multi-valued (full-text search)
 _ssim  = string, stored, indexed, multi-valued (facets)
 _ssi   = string, stored, indexed, single-valued
 _ssm   = string, stored, multi-valued (not indexed)
 _isim  = integer, stored, indexed, multi-valued (range facets)
        │
        ▼
 CatalogController (app/controllers/catalog_controller.rb)
 Defines: facets, index fields, show fields, search fields, sort fields
 Maps Solr field names → display labels and rendering options
        │
        ▼
 Presenters (app/presenters/sinai/*_metadata_presenter.rb)
 Each tab has a presenter inheriting from BaseMetadataPresenter
 (app/presenters/base_metadata_presenter.rb)
 Reads YAML config → filters SolrDocument fields to render
        │
        ▼
 YAML Configs (config/metadata-sinai/*.yml)
 Maps Solr field names → display labels, controls field order per tab
        │
        ▼
 View Templates (app/views/catalog/work_record--sinai/*.html.erb)
 Tab-based layout with CSS radio buttons
 Overview section is non-tabbed, always visible
        │
        ▼
 Helpers (app/helpers/blacklight_helper.rb)
 render_truncated_list() — pipe-separated, max 3 values
 render_overtext_manuscript_links() — clickable links
 iconify_auto_link() — external link icons
```

### Key Files

| Component | Path |
|---|---|
| **Controller** | `app/controllers/catalog_controller.rb` |
| **Base Presenter** | `app/presenters/base_metadata_presenter.rb` |
| **Overview Presenter** | `app/presenters/sinai/overview_metadata_presenter.rb` |
| **All Show Presenters** | `app/presenters/sinai/*.rb` (8 files) |
| **All Index Presenters** | `app/presenters/ursus/sinai_index_*.rb` |
| **Show Page YAML Configs** | `config/metadata-sinai/*.yml` |
| **Index Page YAML Configs** | `config/metadata/sinai_index_*.yml` |
| **Overview View** | `app/views/catalog/work_record--sinai/_item_overview_metadata.html.erb` |
| **Tab Container** | `app/views/catalog/work_record--sinai/_primary_metadata.html.erb` |
| **Secondary Metadata** | `app/views/catalog/work_record--sinai/_secondary_metadata.html.erb` |
| **Index List View** | `app/views/catalog/_index.html.erb` |
| **Index Gallery View** | `app/views/catalog/_index_gallery.html.erb` |
| **Index Field Partials** | `app/views/catalog/index_results/*.html.erb` |
| **Blacklight Helpers** | `app/helpers/blacklight_helper.rb` |
| **Catalog Helpers** | `app/helpers/ursus/catalog_helper.rb` |
| **Solr Document Model** | `app/models/solr_document.rb` |
| **Source JSON Data** | `solr/sinaiportal_data/{ms_objs,layers,text_units,works,agents}/*.json` |
| **JSON Schemas** | `solr/sinaiportal_data/_documentation/schemas/*.json` |
| **Solr Dockerfile** | `solr/Dockerfile` |
| **Data Load Script** | `solr/load_data.sh` |

### How to Add/Modify a Field

1. **If the field already exists as a Solr field**: Add it to the appropriate YAML config in `config/metadata-sinai/` and ensure it's registered in `CatalogController` as a show field.

2. **If the field needs to be extracted from JSON**: The `feed_ursus` indexer must be updated to extract and flatten the new field into a Solr field with the appropriate suffix. Then follow step 1.

3. **If the field needs custom rendering**: Add a helper method in `app/helpers/blacklight_helper.rb` and reference it in the CatalogController field config via the `helper_method` option.

---

## 6. Solr Field Prefixes by Layer Type

Fields in CatalogController are organized by manuscript layer type:

| Prefix | Layer Type | Description | Example Fields |
|---|---|---|---|
| `ot_` | Overtext | The primary/visible text layer | `ot_script_ssim`, `ot_writing_system_ssim`, `ot_genre_ssim`, `ot_language_ssim`, `ot_works_ssim`, `ot_year_isim`, `ot_date_tesim` |
| `para_` | Paracontent / Guest | Supplementary text (colophons, inscriptions) | `para_script_ssim`, `para_writing_system_ssim`, `para_genre_ssim`, `para_language_ssim`, `para_works_ssim`, `para_type_ssim`, `para_names_ssim`, `para_year_isim` |
| `uto_` | Undertext Objects | Hidden/erased text revealed by imaging | `uto_script_ssim`, `uto_writing_system_ssim`, `uto_language_ssim`, `uto_year_isim` |
| _(none)_ | General / ms_obj level | Manuscript-level properties | `features_ssim`, `support_ssim`, `repository_ssim`, `collection_ssim`, `names_ssim`, `places_ssim`, `state_ssi`, `ms_type_ssi` |

---

## 7. Index Page Fields

The search results / index page uses a separate set of presenters and YAML configs:

| Index Field | Solr Field | YAML Config | Presenter |
|---|---|---|---|
| Header/Shelfmark | `header_index_tesim` | N/A (in view) | `app/views/catalog/index_results/_header.html.erb` |
| Works (title) | `ot_works_ssim` | `config/metadata/sinai_index_title_metadata.yml` | `SinaiIndexTitleMetadataPresenter` |
| Date | `ot_date_tesim` | `config/metadata/sinai_index_date.yml` | `SinaiIndexDatePresenter` |
| Language | `ot_language_ssim` | `config/metadata/sinai_index_language.yml` | `SinaiIndexLanguagePresenter` |
| Names | `name_fields_index_tesim` | `config/metadata/sinai_index_name_metadata.yml` | `SinaiIndexNameMetadataPresenter` |
| Collection | `collection_ssim` | `config/metadata/sinai_index_collection.yml` | `SinaiIndexCollectionPresenter` |

---

## 8. Quick Glossary

| Domain Term | Meaning |
|---|---|
| **Manuscript Object (ms_obj)** | A physical codex/manuscript — the top-level record |
| **Part** | A distinct production unit within a ms_obj (most have just one) |
| **Layer** | An inscribed text layer: overtext (visible), undertext (erased/hidden), or guest content |
| **Text Unit** | A discrete text within a layer (e.g., a biblical book, a hymn) |
| **Paracontent** | Supplementary text: colophons, inscriptions, additions, decorations, etc. |
| **Palimpsest** | A manuscript where original text was scraped off and written over — has undertext layers |
| **MSI** | Multispectral Imaging — used to reveal undertext |
| **Overtext (OT)** | The currently visible/top text layer |
| **Undertext (UTO)** | Hidden text layer beneath the overtext, revealed by imaging |
| **Guest Content** | Text added later by a different hand |
| **Locus** | Folio location reference (e.g., "ff. 1-24", "f. 16v") |
| **Viscodex** | External collation visualization tool |
| **ARK** | Archival Resource Key — unique identifier (e.g., `ark:/21198/z12v3d24`) |
| **Shelfmark** | Library shelf classification (e.g., "Sinai Georgian 49") |
| **Collation** | Physical structure of quires/gatherings |
| **Foliation** | Numbering system for folios/pages |
