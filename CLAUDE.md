# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the frontend web app for the [Sinai Manuscripts Digital Library](https://sinaimanuscripts.library.ucla.edu), built on Ruby on Rails 6.1 with [Blacklight](https://projectblacklight.org/) (v7.40) as the search/discovery framework and Apache Solr as the search index.

## Development Setup

```bash
git submodule sync
docker-compose run sinai bundle exec rails db:setup
docker-compose up
```

The app runs at `http://localhost:3004`. Solr runs at `http://localhost:8983`.

Data is maintained as a git submodule at `solr/sinaiportal_data/` (source: https://github.com/UCLALibrary/sinaiportal_data). The Solr Docker image loads this data using the `feed_ursus` Python CLI tool (the `sinai` command) during the Docker build in `solr/Dockerfile`.

Set `SINAI_ID_BYPASS=true` in your environment to skip Sinai authentication in development.

## Commands

```bash
# Run all tests (requires solr_test running on port 8985)
bundle exec rspec

# Run a single test file
bundle exec rspec spec/path/to/spec.rb

# Lint Ruby
bundle exec rubocop

# Lint ERB templates
bundle exec erb_lint
```

## Architecture

### Blacklight + Solr

`CatalogController` is the central configuration point. It uses Blacklight's DSL to configure:
- **Facets** (`add_facet_field`) — organized by manuscript layer type: main (all), OT (overtext), Para/Guest, UTO
- **Index/search result fields** (`add_index_field`)
- **Show/item page fields** (`add_show_field`)
- **Search fields** (`add_search_field`) — dropdown options in the search bar
- **Sort fields** (`add_sort_field`) — defaults to shelfmark A-Z

The default Solr filter query (`fq`) restricts to `has_model_ssim:Work` and excludes `visibility_ssi:restricted` when the `sinai` feature flag is active.

### Solr Field Naming (Solrizer conventions)

- `_tesim` — text, stored, indexed, multi-valued (full-text searchable)
- `_ssi` — string, stored, indexed, single-valued
- `_ssim` — string, stored, indexed, multi-valued (used for facets)
- `_ssm` — string, stored, multi-valued (not indexed)
- `_isim` — integer, stored, indexed, multi-valued (used for range facets)

### Feature Flags (Flipflop)

Two flags defined in `config/features.rb`:
- `sinai` (default: `true`) — enables Sinai-specific styling, auth, and Solr query filtering. Checked throughout the codebase via `Flipflop.sinai?`. Toggle at `/flipflop`.
- `use_manifest_store` (default: `true`) — loads IIIF manifests from an external service.

### Metadata Presenters

The item show page uses a tab-based layout. Each tab is driven by a presenter in `app/presenters/sinai/` (overview, codicology, contents, history, decoration, keywords, references). All inherit from `BaseMetadataPresenter`, which reads a YAML config file from `config/metadata-sinai/` to determine which Solr fields to render. To change which fields appear on a tab, edit the corresponding YAML file.

### Authentication

`ApplicationController#sinai_authn_check` enforces Sinai authentication on every request. It checks for a `sinai_authenticated_1year` cookie. Auth flow uses UCLA tokens via `LoginService` and `SinaiToken`. Bypass in development with `SINAI_ID_BYPASS` env var.

### View Layer

`ApplicationController#add_legacy_views` prepends `app/views_legacy/` to the view path (before `app/views/`). This allows gradual migration of views without deleting legacy ones. The Sinai item page renders tabs via `app/views/catalog/work_record--sinai/`.

### SMDL Data Model & Field Reference

See `code_docs/SMDL_FIELD_REFERENCE.md` for the comprehensive guide mapping between:
- **Dawn's JIRA ticket notation** (JSON path syntax, `solr:` prefix, display rules)
- **JSON data model** hierarchy (ms_obj > part > layer > text_unit) and reusable sub-objects (paracontent, assoc_date, assoc_place, assoc_name)
- **Solr field names** and layer-type prefixes (`ot_`, `para_`, `uto_`)
- **Code rendering pipeline** (Solr → CatalogController → Presenter → YAML config → View template)

When working on SMDL-prefixed JIRA tickets, always consult this reference to trace fields from ticket notation to code location. The source JSON data and schemas are in `solr/sinaiportal_data/` and `solr/sinaiportal_data/_documentation/schemas/`.

### OAI-PMH

OAI-PMH endpoint is at `/catalog/oai`. Field mappings for Dublin Core and other schemas are defined in `config/oai.yml` and loaded into `SolrDocument` at startup.

## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- For cross-module "how does X relate to Y" questions, prefer `graphify query "<question>"`, `graphify path "<A>" "<B>"`, or `graphify explain "<concept>"` over grep — these traverse the graph's EXTRACTED + INFERRED edges instead of scanning files
- After modifying code files in this session, run `graphify update .` to keep the graph current (AST-only, no API cost)
