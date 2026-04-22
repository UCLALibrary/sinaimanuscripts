# Graph Report - .  (2026-04-22)

## Corpus Check
- 111 files · ~41,580 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 532 nodes · 538 edges · 65 communities detected
- Extraction: 94% EXTRACTED · 6% INFERRED · 0% AMBIGUOUS · INFERRED: 33 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_SMDL Data Model|SMDL Data Model]]
- [[_COMMUNITY_Blacklight Helpers|Blacklight Helpers]]
- [[_COMMUNITY_ApplicationController|ApplicationController]]
- [[_COMMUNITY_Full Description Screenshot|Full Description Screenshot]]
- [[_COMMUNITY_Dynamic Sitemap|Dynamic Sitemap]]
- [[_COMMUNITY_Stakeholders & Rebuild Scope|Stakeholders & Rebuild Scope]]
- [[_COMMUNITY_Range-Limit Distro Facets (JS)|Range-Limit Distro Facets (JS)]]
- [[_COMMUNITY_Blacklight Helper (Sinai)|Blacklight Helper (Sinai)]]
- [[_COMMUNITY_OAI DPLA Library|OAI DPLA Library]]
- [[_COMMUNITY_SolrDocument|SolrDocument]]
- [[_COMMUNITY_Metadata Presenters|Metadata Presenters]]
- [[_COMMUNITY_StaticController|StaticController]]
- [[_COMMUNITY_ThumbnailPresenter|ThumbnailPresenter]]
- [[_COMMUNITY_IIIF Service|IIIF Service]]
- [[_COMMUNITY_CanonLawController|CanonLawController]]
- [[_COMMUNITY_Layout Helpers|Layout Helpers]]
- [[_COMMUNITY_CollectionBlockPresenter|CollectionBlockPresenter]]
- [[_COMMUNITY_CatalogController|CatalogController]]
- [[_COMMUNITY_SolrDocumentWrapper (OAI)|SolrDocumentWrapper (OAI)]]
- [[_COMMUNITY_AutoLink Processor|AutoLink Processor]]
- [[_COMMUNITY_OAI DPLA Metadata|OAI DPLA Metadata]]
- [[_COMMUNITY_HistoryMetadataPresenter|HistoryMetadataPresenter]]
- [[_COMMUNITY_ContentsWorksMetadataPresenter|ContentsWorksMetadataPresenter]]
- [[_COMMUNITY_ReferencesMetadataPresenter|ReferencesMetadataPresenter]]
- [[_COMMUNITY_CodicologyMetadataPresenter|CodicologyMetadataPresenter]]
- [[_COMMUNITY_Keywords Metadata Presenter|Keywords Metadata Presenter]]
- [[_COMMUNITY_Decoration Metadata Presenter|Decoration Metadata Presenter]]
- [[_COMMUNITY_Overview Metadata Presenter|Overview Metadata Presenter]]
- [[_COMMUNITY_Contents Metadata Presenter|Contents Metadata Presenter]]
- [[_COMMUNITY_Find This Item Metadata Presenter|Find This Item Metadata Presenter]]
- [[_COMMUNITY_Sinai Index Date Presenter|Sinai Index Date Presenter]]
- [[_COMMUNITY_Tagline Metadata Presenter|Tagline Metadata Presenter]]
- [[_COMMUNITY_Contact Collection Metadata Presenter|Contact Collection Metadata Presenter]]
- [[_COMMUNITY_Keyword Metadata Presenter|Keyword Metadata Presenter]]
- [[_COMMUNITY_Note Collection Metadata Presenter|Note Collection Metadata Presenter]]
- [[_COMMUNITY_Sinai Index Name Metadata Presenter|Sinai Index Name Metadata Presenter]]
- [[_COMMUNITY_Sinai Index Collection Presenter|Sinai Index Collection Presenter]]
- [[_COMMUNITY_Find Collection Metadata Presenter|Find Collection Metadata Presenter]]
- [[_COMMUNITY_Item Overview Metadata Presenter|Item Overview Metadata Presenter]]
- [[_COMMUNITY_Access Condition Metadata Presenter|Access Condition Metadata Presenter]]
- [[_COMMUNITY_Sinai Index Text Unit Labels Presenter|Sinai Index Text Unit Labels Presenter]]
- [[_COMMUNITY_Note Metadata Presenter|Note Metadata Presenter]]
- [[_COMMUNITY_Sinai Index Language Presenter|Sinai Index Language Presenter]]
- [[_COMMUNITY_Sinai Index Title Metadata Presenter|Sinai Index Title Metadata Presenter]]
- [[_COMMUNITY_Physical Description Metadata Presenter|Physical Description Metadata Presenter]]
- [[_COMMUNITY_Blacklight|Blacklight]]
- [[_COMMUNITY_Range Limit Slider|Range Limit Slider]]
- [[_COMMUNITY_Search Field Service|Search Field Service]]
- [[_COMMUNITY_Login Service|Login Service]]
- [[_COMMUNITY_Solr Document Provider|Solr Document Provider]]
- [[_COMMUNITY_Application Mailer|Application Mailer]]
- [[_COMMUNITY_Ability|Ability]]
- [[_COMMUNITY_Search Builder|Search Builder]]
- [[_COMMUNITY_Application Record|Application Record]]
- [[_COMMUNITY_Application Job|Application Job]]
- [[_COMMUNITY_Search History Controller|Search History Controller]]
- [[_COMMUNITY_Scrollable Tabs|Scrollable Tabs]]
- [[_COMMUNITY_Work Show More|Work Show More]]
- [[_COMMUNITY_Range Limit Shared|Range Limit Shared]]
- [[_COMMUNITY_Facet Label Button Behavior|Facet Label Button Behavior]]
- [[_COMMUNITY_Channel|Channel]]
- [[_COMMUNITY_Onboarding Transcript|Onboarding Transcript]]
- [[_COMMUNITY_Onboarding Transcript|Onboarding Transcript]]
- [[_COMMUNITY_Smdl Field Reference|Smdl Field Reference]]
- [[_COMMUNITY_Smdl Overview|Smdl Overview]]

## God Nodes (most connected - your core abstractions)
1. `ApplicationController` - 21 edges
2. `Manuscript Object (ms_obj)` - 14 edges
3. `Overview Section` - 14 edges
4. `Inscribed Layer` - 11 edges
5. `Sitemap` - 10 edges
6. `StaticController` - 9 edges
7. `areaChart()` - 8 edges
8. `SolrDocument` - 7 edges
9. `CanonLawController` - 7 edges
10. `presenter()` - 7 edges

## Surprising Connections (you probably didn't know these)
- `render_thumbnail_tag()` --calls--> `index_presenter()`  [INFERRED]
  /Users/ayem/workspace/ucla/sinaimanuscripts/app/helpers/ursus/catalog_helper.rb → /Users/ayem/workspace/ucla/sinaimanuscripts/app/helpers/blacklight/blacklight_helper_behavior.rb
- `Sample JSON fixtures (5 fake-data records)` --shares_data_with--> `Manuscript Object (ms_obj)`  [INFERRED]
  code_docs/onboarding/onboarding_transcript.txt → code_docs/SMDL_FIELD_REFERENCE.md
- `Rationale: Reusable paracontent template ticket mirrors Blacklight partial reuse` --semantically_similar_to--> `Rationale: Reusable Rails view partials mirror reusable JSON sub-objects`  [INFERRED] [semantically similar]
  code_docs/onboarding/onboarding_transcript.txt → code_docs/SMDL_FIELD_REFERENCE.md
- `areaChart()` --calls--> `Plot()`  [INFERRED]
  /Users/ayem/workspace/ucla/sinaimanuscripts/app/assets/javascripts/blacklight_range_limit/range_limit_distro_facets.js → /Users/ayem/workspace/ucla/sinaimanuscripts/app/assets/javascripts/flot/jquery.flot.js
- `link_to_featured_work()` --calls--> `Connection`  [INFERRED]
  /Users/ayem/workspace/ucla/sinaimanuscripts/app/helpers/home_page_helper.rb → /Users/ayem/workspace/ucla/sinaimanuscripts/app/channels/application_cable/connection.rb

## Hyperedges (group relationships)
- **JSON to HTML rendering pipeline** — smdl_field_reference_feed_ursus, smdl_field_reference_solr_index, smdl_field_reference_catalog_controller, smdl_field_reference_base_metadata_presenter, smdl_field_reference_yaml_configs, smdl_field_reference_view_templates [EXTRACTED 1.00]
- **ms_obj > part > layer > text_unit hierarchy** — smdl_field_reference_ms_obj, smdl_field_reference_part, smdl_field_reference_layer, smdl_field_reference_text_unit [EXTRACTED 1.00]
- **OT/Para/UTO/Guest layer type classification** — smdl_field_reference_overtext_layer, smdl_field_reference_undertext_layer, smdl_field_reference_guest_layer, smdl_field_reference_paracontent, smdl_field_reference_layer_prefix_system [EXTRACTED 1.00]

## Communities

### Community 0 - "SMDL Data Model"
Cohesion: 0.09
Nodes (36): Dawn Childress (domain/notation owner), Figma Designs (front end layouts), Rationale: Granular JSON data model (Dawn: 'probably made it too granular but awesome'), Rationale: Reusable paracontent template ticket mirrors Blacklight partial reuse, Sample JSON fixtures (5 fake-data records), Rationale: SMDL combines ms_obj/layer/text_unit into one JSON record (Data Portal keeps them separate), SMDL JIRA Ticket Prefix, Rationale: Notation solves communication wall between domain expert and devs (+28 more)

### Community 1 - "Blacklight Helpers"
Cohesion: 0.14
Nodes (32): application_name(), blacklight_path(), document_has_value?(), document_heading(), document_index_view_type(), document_presenter(), document_presenter_class(), document_show_html_title() (+24 more)

### Community 2 - "ApplicationController"
Cohesion: 0.08
Nodes (5): ApplicationController, iconify_auto_link(), render_index_field_label(), render_opensearch_response_metadata(), CustomJoin

### Community 3 - "Full Description Screenshot"
Cohesion: 0.13
Nodes (19): Collation field (coll, note where type.id=collation, viscodex), Current state field (state_ssi), Extent field (extent, dim, weight), Figma layout (referenced), Foliation field (fol, note where type.id=foliation), Full Description Tab, JSON Blob (data source), Keywords field (features_ssim, ot_genre_ssim) (+11 more)

### Community 4 - "Dynamic Sitemap"
Cohesion: 0.14
Nodes (5): Connection, blank_search_path(), create_representative_image(), link_to_featured_work(), Sitemap

### Community 5 - "Stakeholders & Rebuild Scope"
Cohesion: 0.13
Nodes (18): Data Structure Migration (backend), Lisa McAulay (Project Manager), Monica (frontend dev, Piotr's collaborator), Piotr Nowak (Nopio frontend dev), Sinai Data Portal (sinai.library.ucla.edu), SMDL Frontend Rebuild (epic), Tatiana (backend dev; data structure migration), Rationale: Tatiana finishes backend before Piotr takes over frontend (avoid mid-task handoff) (+10 more)

### Community 6 - "Range-Limit Distro Facets (JS)"
Cohesion: 0.28
Nodes (11): Canvas(), clamp(), floorInBase(), Plot(), areaChart(), domDependenciesMet(), form_selection(), function_for_find_segment() (+3 more)

### Community 7 - "Blacklight Helper (Sinai)"
Cohesion: 0.25
Nodes (13): license_markup(), other_versions_markup(), overtext_manuscript_markup(), render_license(), render_opac_link(), render_other_versions_link(), render_overtext_manuscript_links(), render_table_of_contents_key() (+5 more)

### Community 8 - "OAI DPLA Library"
Cohesion: 0.31
Nodes (13): build_xml_tag(), dc_field_name?(), dc_field_names(), dcterms_field_name?(), dcterms_field_names(), dpla_field_name?(), dpla_field_names(), edm_field_name?() (+5 more)

### Community 9 - "SolrDocument"
Cohesion: 0.14
Nodes (2): SolrDocument, User

### Community 10 - "Metadata Presenters"
Cohesion: 0.2
Nodes (2): BaseMetadataPresenter, CollectionOverviewMetadataPresenter

### Community 11 - "StaticController"
Cohesion: 0.2
Nodes (1): StaticController

### Community 12 - "ThumbnailPresenter"
Cohesion: 0.25
Nodes (3): render_thumbnail_tag(), render_truncated_description(), ThumbnailPresenter

### Community 13 - "IIIF Service"
Cohesion: 0.28
Nodes (2): Application, IiifService

### Community 14 - "CanonLawController"
Cohesion: 0.25
Nodes (1): CanonLawController

### Community 15 - "Layout Helpers"
Cohesion: 0.48
Nodes (5): container_classes(), main_content_classes(), show_content_classes(), show_sidebar_classes(), sidebar_classes()

### Community 16 - "CollectionBlockPresenter"
Cohesion: 0.33
Nodes (1): CollectionBlockPresenter

### Community 17 - "CatalogController"
Cohesion: 0.33
Nodes (1): CatalogController

### Community 18 - "SolrDocumentWrapper (OAI)"
Cohesion: 0.33
Nodes (1): SolrDocumentWrapper

### Community 19 - "AutoLink Processor"
Cohesion: 0.5
Nodes (1): AutoLink

### Community 20 - "OAI DPLA Metadata"
Cohesion: 0.4
Nodes (1): Dpla

### Community 21 - "HistoryMetadataPresenter"
Cohesion: 0.5
Nodes (1): HistoryMetadataPresenter

### Community 22 - "ContentsWorksMetadataPresenter"
Cohesion: 0.5
Nodes (1): ContentsWorksMetadataPresenter

### Community 23 - "ReferencesMetadataPresenter"
Cohesion: 0.5
Nodes (1): ReferencesMetadataPresenter

### Community 24 - "CodicologyMetadataPresenter"
Cohesion: 0.5
Nodes (1): CodicologyMetadataPresenter

### Community 25 - "Keywords Metadata Presenter"
Cohesion: 0.5
Nodes (1): KeywordsMetadataPresenter

### Community 26 - "Decoration Metadata Presenter"
Cohesion: 0.5
Nodes (1): DecorationMetadataPresenter

### Community 27 - "Overview Metadata Presenter"
Cohesion: 0.5
Nodes (1): OverviewMetadataPresenter

### Community 28 - "Contents Metadata Presenter"
Cohesion: 0.5
Nodes (1): ContentsMetadataPresenter

### Community 29 - "Find This Item Metadata Presenter"
Cohesion: 0.5
Nodes (1): FindThisItemMetadataPresenter

### Community 30 - "Sinai Index Date Presenter"
Cohesion: 0.5
Nodes (1): SinaiIndexDatePresenter

### Community 31 - "Tagline Metadata Presenter"
Cohesion: 0.5
Nodes (1): TaglineMetadataPresenter

### Community 32 - "Contact Collection Metadata Presenter"
Cohesion: 0.5
Nodes (1): ContactCollectionMetadataPresenter

### Community 33 - "Keyword Metadata Presenter"
Cohesion: 0.5
Nodes (1): KeywordMetadataPresenter

### Community 34 - "Note Collection Metadata Presenter"
Cohesion: 0.5
Nodes (1): NoteCollectionMetadataPresenter

### Community 35 - "Sinai Index Name Metadata Presenter"
Cohesion: 0.5
Nodes (1): SinaiIndexNameMetadataPresenter

### Community 36 - "Sinai Index Collection Presenter"
Cohesion: 0.5
Nodes (1): SinaiIndexCollectionPresenter

### Community 37 - "Find Collection Metadata Presenter"
Cohesion: 0.5
Nodes (1): FindCollectionMetadataPresenter

### Community 38 - "Item Overview Metadata Presenter"
Cohesion: 0.5
Nodes (1): ItemOverviewMetadataPresenter

### Community 39 - "Access Condition Metadata Presenter"
Cohesion: 0.5
Nodes (1): AccessConditionMetadataPresenter

### Community 40 - "Sinai Index Text Unit Labels Presenter"
Cohesion: 0.5
Nodes (1): SinaiIndexTextUnitLabelsPresenter

### Community 41 - "Note Metadata Presenter"
Cohesion: 0.5
Nodes (1): NoteMetadataPresenter

### Community 42 - "Sinai Index Language Presenter"
Cohesion: 0.5
Nodes (1): SinaiIndexLanguagePresenter

### Community 43 - "Sinai Index Title Metadata Presenter"
Cohesion: 0.5
Nodes (1): SinaiIndexTitleMetadataPresenter

### Community 44 - "Physical Description Metadata Presenter"
Cohesion: 0.5
Nodes (1): PhysicalDescriptionMetadataPresenter

### Community 45 - "Blacklight"
Cohesion: 0.67
Nodes (2): longer(), updateStateFor()

### Community 46 - "Range Limit Slider"
Cohesion: 0.67
Nodes (2): isInt(), min_max()

### Community 47 - "Search Field Service"
Cohesion: 0.5
Nodes (1): SearchFieldService

### Community 48 - "Login Service"
Cohesion: 0.5
Nodes (1): LoginService

### Community 49 - "Solr Document Provider"
Cohesion: 0.5
Nodes (1): SolrDocumentProvider

### Community 50 - "Application Mailer"
Cohesion: 0.67
Nodes (1): ApplicationMailer

### Community 51 - "Ability"
Cohesion: 0.67
Nodes (1): Ability

### Community 52 - "Search Builder"
Cohesion: 0.67
Nodes (1): SearchBuilder

### Community 53 - "Application Record"
Cohesion: 0.67
Nodes (1): ApplicationRecord

### Community 54 - "Application Job"
Cohesion: 0.67
Nodes (1): ApplicationJob

### Community 55 - "Search History Controller"
Cohesion: 0.67
Nodes (1): SearchHistoryController

### Community 56 - "Scrollable Tabs"
Cohesion: 0.67
Nodes (1): initScrollableTabs()

### Community 57 - "Work Show More"
Cohesion: 0.67
Nodes (1): initWorkShowMore()

### Community 58 - "Range Limit Shared"
Cohesion: 0.67
Nodes (1): BlacklightRangeLimit()

### Community 59 - "Facet Label Button Behavior"
Cohesion: 0.67
Nodes (1): render_selected_facet_value()

### Community 60 - "Channel"
Cohesion: 0.67
Nodes (1): Channel

### Community 61 - "Onboarding Transcript"
Cohesion: 1.0
Nodes (2): Andy Wallace (DevOps / Blacklight auth), Blacklight 8 Authentication Regression

### Community 62 - "Onboarding Transcript"
Cohesion: 1.0
Nodes (2): Staging Regression (build rollback), Staging Site (stage.sinaimanuscripts.library.ucla.edu)

### Community 143 - "Smdl Field Reference"
Cohesion: 1.0
Nodes (1): Locus (folio reference)

### Community 144 - "Smdl Overview"
Cohesion: 1.0
Nodes (1): smdl_overview.md (empty file)

## Knowledge Gaps
- **38 isolated node(s):** `Writing (writing[])`, `Palimpsest`, `Multispectral Imaging (MSI)`, `ARK (Archival Resource Key)`, `Shelfmark` (+33 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `SolrDocument`** (14 nodes): `solr_document.rb`, `user.rb`, `.set_default_sort()`, `.access_list()`, `SolrDocument`, `.add_field_semantics()`, `.export_as_ucla_citation_txt()`, `.permalink()`, `.root_url()`, `.to_semantic_values()`, `User`, `.to_s()`, `solr_document.rb`, `user.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Metadata Presenters`** (11 nodes): `base_metadata_presenter.rb`, `collection_overview_metadata_presenter.rb`, `BaseMetadataPresenter`, `.fields_to_render_by_config_keys()`, `.fields_to_render_by_keys()`, `.initialize()`, `CollectionOverviewMetadataPresenter`, `.overview_labels()`, `.overview_terms()`, `base_metadata_presenter.rb`, `collection_overview_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `StaticController`** (10 nodes): `static_controller.rb`, `StaticController`, `.about()`, `.contact()`, `.contributors_credits()`, `.manuscript_descriptions()`, `.references()`, `.terms_of_use()`, `.version()`, `static_controller.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `IIIF Service`** (9 nodes): `iiif_service.rb`, `Application`, `application.rb`, `IiifService`, `.iiif_manifest_url()`, `.media_viewer_url()`, `.src()`, `iiif_service.rb`, `application.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `CanonLawController`** (8 nodes): `canon_law_controller.rb`, `CanonLawController`, `.index()`, `.introduction()`, `.margarita()`, `.materiae()`, `.table_of_contents()`, `canon_law_controller.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `CollectionBlockPresenter`** (6 nodes): `collection_block_presenter.rb`, `CollectionBlockPresenter`, `.collection_document()`, `.collection_selected?()`, `.initialize()`, `collection_block_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `CatalogController`** (6 nodes): `catalog_controller.rb`, `CatalogController`, `.enforce_show_permissions()`, `.oai_provider()`, `.show()`, `catalog_controller.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `SolrDocumentWrapper (OAI)`** (6 nodes): `solr_document_wrapper.rb`, `SolrDocumentWrapper`, `.conditions()`, `.earliest()`, `.latest()`, `solr_document_wrapper.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `AutoLink Processor`** (5 nodes): `auto_link.rb`, `AutoLink`, `.html_escape()`, `.render()`, `auto_link.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `OAI DPLA Metadata`** (5 nodes): `Dpla`, `.header_specification()`, `.initialize()`, `dpla.rb`, `dpla.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `HistoryMetadataPresenter`** (4 nodes): `history_metadata_presenter.rb`, `HistoryMetadataPresenter`, `.history_terms()`, `history_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `ContentsWorksMetadataPresenter`** (4 nodes): `contents_works_metadata_presenter.rb`, `ContentsWorksMetadataPresenter`, `.contents_terms()`, `contents_works_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `ReferencesMetadataPresenter`** (4 nodes): `references_metadata_presenter.rb`, `ReferencesMetadataPresenter`, `.references_terms()`, `references_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `CodicologyMetadataPresenter`** (4 nodes): `codicology_metadata_presenter.rb`, `CodicologyMetadataPresenter`, `.codicology_terms()`, `codicology_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Keywords Metadata Presenter`** (4 nodes): `keywords_metadata_presenter.rb`, `KeywordsMetadataPresenter`, `.keywords_terms()`, `keywords_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Decoration Metadata Presenter`** (4 nodes): `decoration_metadata_presenter.rb`, `DecorationMetadataPresenter`, `.decoration_terms()`, `decoration_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Overview Metadata Presenter`** (4 nodes): `overview_metadata_presenter.rb`, `OverviewMetadataPresenter`, `.overview_terms()`, `overview_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Contents Metadata Presenter`** (4 nodes): `contents_metadata_presenter.rb`, `ContentsMetadataPresenter`, `.contents_terms()`, `contents_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Find This Item Metadata Presenter`** (4 nodes): `find_this_item_metadata_presenter.rb`, `FindThisItemMetadataPresenter`, `.find_this_item_terms()`, `find_this_item_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Sinai Index Date Presenter`** (4 nodes): `sinai_index_date_presenter.rb`, `SinaiIndexDatePresenter`, `.sinai_index_date_terms()`, `sinai_index_date_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Tagline Metadata Presenter`** (4 nodes): `tagline_metadata_presenter.rb`, `TaglineMetadataPresenter`, `.tagline_terms()`, `tagline_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Contact Collection Metadata Presenter`** (4 nodes): `contact_collection_metadata_presenter.rb`, `ContactCollectionMetadataPresenter`, `.contact_collection_terms()`, `contact_collection_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Keyword Metadata Presenter`** (4 nodes): `keyword_metadata_presenter.rb`, `KeywordMetadataPresenter`, `.keyword_terms()`, `keyword_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Note Collection Metadata Presenter`** (4 nodes): `note_collection_metadata_presenter.rb`, `NoteCollectionMetadataPresenter`, `.note_collection_terms()`, `note_collection_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Sinai Index Name Metadata Presenter`** (4 nodes): `sinai_index_name_metadata_presenter.rb`, `SinaiIndexNameMetadataPresenter`, `.sinai_index_name_terms()`, `sinai_index_name_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Sinai Index Collection Presenter`** (4 nodes): `sinai_index_collection_presenter.rb`, `SinaiIndexCollectionPresenter`, `.sinai_index_collection_terms()`, `sinai_index_collection_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Find Collection Metadata Presenter`** (4 nodes): `find_collection_metadata_presenter.rb`, `FindCollectionMetadataPresenter`, `.find_collection_terms()`, `find_collection_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Item Overview Metadata Presenter`** (4 nodes): `item_overview_metadata_presenter.rb`, `ItemOverviewMetadataPresenter`, `.overview_terms()`, `item_overview_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Access Condition Metadata Presenter`** (4 nodes): `AccessConditionMetadataPresenter`, `.access_condition_terms()`, `access_condition_metadata_presenter.rb`, `access_condition_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Sinai Index Text Unit Labels Presenter`** (4 nodes): `sinai_index_text_unit_labels_presenter.rb`, `SinaiIndexTextUnitLabelsPresenter`, `.sinai_index_text_unit_labels_terms()`, `sinai_index_text_unit_labels_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Note Metadata Presenter`** (4 nodes): `note_metadata_presenter.rb`, `NoteMetadataPresenter`, `.note_terms()`, `note_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Sinai Index Language Presenter`** (4 nodes): `sinai_index_language_presenter.rb`, `SinaiIndexLanguagePresenter`, `.sinai_index_language_terms()`, `sinai_index_language_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Sinai Index Title Metadata Presenter`** (4 nodes): `sinai_index_title_metadata_presenter.rb`, `SinaiIndexTitleMetadataPresenter`, `.sinai_index_title_terms()`, `sinai_index_title_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Physical Description Metadata Presenter`** (4 nodes): `physical_description_metadata_presenter.rb`, `PhysicalDescriptionMetadataPresenter`, `.physical_description_terms()`, `physical_description_metadata_presenter.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Blacklight`** (4 nodes): `blacklight.js`, `longer()`, `updateStateFor()`, `blacklight.js`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Range Limit Slider`** (4 nodes): `range_limit_slider.js`, `isInt()`, `min_max()`, `range_limit_slider.js`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Search Field Service`** (4 nodes): `search_field_service.rb`, `SearchFieldService`, `.search_fields()`, `search_field_service.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Login Service`** (4 nodes): `login_service.rb`, `LoginService`, `.create_token()`, `login_service.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Solr Document Provider`** (4 nodes): `solr_document_provider.rb`, `SolrDocumentProvider`, `.initialize()`, `solr_document_provider.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Application Mailer`** (3 nodes): `application_mailer.rb`, `ApplicationMailer`, `application_mailer.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Ability`** (3 nodes): `Ability`, `ability.rb`, `ability.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Search Builder`** (3 nodes): `search_builder.rb`, `SearchBuilder`, `search_builder.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Application Record`** (3 nodes): `application_record.rb`, `ApplicationRecord`, `application_record.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Application Job`** (3 nodes): `application_job.rb`, `ApplicationJob`, `application_job.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Search History Controller`** (3 nodes): `search_history_controller.rb`, `SearchHistoryController`, `search_history_controller.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Scrollable Tabs`** (3 nodes): `scrollable_tabs.js`, `initScrollableTabs()`, `scrollable_tabs.js`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Work Show More`** (3 nodes): `work_show_more.js`, `work_show_more.js`, `initWorkShowMore()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Range Limit Shared`** (3 nodes): `range_limit_shared.js`, `BlacklightRangeLimit()`, `range_limit_shared.js`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Facet Label Button Behavior`** (3 nodes): `facet_label_button_behavior.rb`, `render_selected_facet_value()`, `facet_label_button_behavior.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Channel`** (3 nodes): `channel.rb`, `Channel`, `channel.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Onboarding Transcript`** (2 nodes): `Andy Wallace (DevOps / Blacklight auth)`, `Blacklight 8 Authentication Regression`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Onboarding Transcript`** (2 nodes): `Staging Regression (build rollback)`, `Staging Site (stage.sinaimanuscripts.library.ucla.edu)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Smdl Field Reference`** (1 nodes): `Locus (folio reference)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Smdl Overview`** (1 nodes): `smdl_overview.md (empty file)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ApplicationController` connect `ApplicationController` to `SolrDocument`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **Why does `Sitemap` connect `Dynamic Sitemap` to `SolrDocument`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Why does `render_search_bar()` connect `Blacklight Helpers` to `ApplicationController`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **What connects `Writing (writing[])`, `Palimpsest`, `Multispectral Imaging (MSI)` to the rest of the system?**
  _38 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `SMDL Data Model` be split into smaller, more focused modules?**
  _Cohesion score 0.09 - nodes in this community are weakly interconnected._
- **Should `Blacklight Helpers` be split into smaller, more focused modules?**
  _Cohesion score 0.14 - nodes in this community are weakly interconnected._
- **Should `ApplicationController` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._