# frozen_string_literal: true

# Helpers for the "Names, Dates, Places" item-page tab (NOP-161).
#
# Aggregates every assoc_name / assoc_date / assoc_place object from ANYWHERE in
# the manuscript JSON blob (ms_obj root, paracontent, parts, overtext/guest
# layers, and text units) and returns them as three display-ready, sorted lists.
#
# Each returned entry is a Hash: { display:, as_written:, notes: [] } where
# `display` is the concatenated one-line title per the ticket notation:
#   Name:  {pref_name||value} ({role.label}[, Guest Content]), {locus}
#   Date:  {value} ({type.label}[, {part.label}][, Guest Content]), {locus}
#   Place: {pref_name||value} ({event.label}[, Guest Content]), {locus}
#
# Rules (see ticket NOP-161 / code_docs/SMDL_FIELD_REFERENCE.md):
# - pref_name (agent_record/place_record) is optional; fall back to `value`.
# - The part label ({part.label}, already stored as e.g. "Part 1") is shown only
#   on an origin date (type.id == 'origin') reached within a part's overtext
#   layer (part.ot_layer). It is never synthesised for names/places.
# - "Guest Content" is appended when the object sits within a guest layer
#   (guest_layer wrapper or layer_record.state.id == 'guest').
# - `locus` comes only from the parent paracontent (para.locus); omitted otherwise.
module NamesDatesPlacesHelper
  # Public entry point. Returns { names: [...], dates: [...], places: [...] },
  # each list sorted (names/places alphabetically by display name, dates
  # chronologically by iso.not_before) with a stable fall-back to order of
  # appearance. Memoised per document so the tab-nav presence check and the
  # partial share a single traversal.
  def names_dates_places_for(document)
    @names_dates_places_cache ||= {}
    cache_key = document.respond_to?(:id) ? document.id : document.object_id
    @names_dates_places_cache[cache_key] ||= build_names_dates_places(document)
  end

  private

    def build_names_dates_places(document)
      ms_json = begin
        JSON.parse(document['manuscript_json_ts'] || '{}')
      rescue StandardError
        {}
      end

      acc = { names: [], dates: [], places: [], seq: 0, seen_layers: {} }
      ndp_walk(ms_json, { part_label: nil, in_ot_layer: false, in_guest_layer: false, para_locus: nil }, acc)

      {
        names: ndp_sort(acc[:names]),
        dates: ndp_sort(acc[:dates]),
        places: ndp_sort(acc[:places])
      }
    end

    # Recursively walk the blob, collecting assoc arrays at each node and
    # descending the known wrapper keys while accumulating display context.
    # Context flags are only ever set (they propagate down), never unset.
    def ndp_walk(node, ctx, acc)
      return unless node.is_a?(Hash)

      # A layer_record with a guest state establishes guest context for its subtree.
      ctx = ctx.merge(in_guest_layer: true) if node.dig('state', 'id') == 'guest'
      ndp_collect(node, ctx, acc)
      ndp_descend(node, ctx, acc)
    end

    def ndp_collect(node, ctx, acc)
      Array(node['assoc_name']).each  { |x| ndp_push(acc, :names, ndp_build_name(x, ctx)) }
      Array(node['assoc_date']).each  { |x| ndp_push(acc, :dates, ndp_build_date(x, ctx)) }
      Array(node['assoc_place']).each { |x| ndp_push(acc, :places, ndp_build_place(x, ctx)) }
    end

    def ndp_descend(node, ctx, acc)
      Array(node['para']).each { |pa| ndp_walk(pa, ctx.merge(para_locus: pa['locus']), acc) }
      Array(node['part']).each { |pt| ndp_walk(pt, ctx.merge(part_label: pt['label']), acc) }
      ndp_descend_layers(node, ctx, acc)
    end

    # Layer wrappers hold the actual record under `layer_record` / `text_unit_record`.
    def ndp_descend_layers(node, ctx, acc)
      Array(node['ot_layer']).each    { |ol| ndp_descend_layer(ol, ctx.merge(in_ot_layer: true), acc) }
      Array(node['guest_layer']).each { |gl| ndp_descend_layer(gl, ctx.merge(in_guest_layer: true), acc) }
      Array(node['text_unit']).each   { |tu| ndp_walk(tu['text_unit_record'], ctx, acc) if tu.is_a?(Hash) }
    end

    # The merged blob denormalises guest layers to both the ms_obj root and the
    # owning part, so walk each layer_record at most once (keyed by its ark) to
    # avoid double-counting its associated names/dates/places.
    def ndp_descend_layer(wrapper, ctx, acc)
      return unless wrapper.is_a?(Hash)

      record = wrapper['layer_record']
      return unless record.is_a?(Hash)

      ark = record['ark']
      return if ark.present? && acc[:seen_layers].key?(ark)

      acc[:seen_layers][ark] = true if ark.present?
      ndp_walk(record, ctx, acc)
    end

    def ndp_push(acc, group, entry)
      return unless entry

      entry[:seq] = acc[:seq]
      acc[:seq] += 1
      acc[group] << entry
    end

    def ndp_build_name(assoc, ctx)
      name = assoc.dig('agent_record', 'pref_name').to_s.presence || assoc['value'].to_s.presence
      return nil if name.blank?

      quals = [assoc.dig('role', 'label').to_s.presence]
      quals << 'Guest Content' if ctx[:in_guest_layer]
      ndp_entry(name, quals, ctx[:para_locus], assoc, name.downcase)
    end

    def ndp_build_place(assoc, ctx)
      name = assoc.dig('place_record', 'pref_name').to_s.presence || assoc['value'].to_s.presence
      return nil if name.blank?

      quals = [assoc.dig('event', 'label').to_s.presence]
      quals << 'Guest Content' if ctx[:in_guest_layer]
      ndp_entry(name, quals, ctx[:para_locus], assoc, name.downcase)
    end

    def ndp_build_date(assoc, ctx)
      value = assoc['value'].to_s.presence
      return nil if value.blank?

      quals = [assoc.dig('type', 'label').to_s.presence]
      quals << ctx[:part_label].to_s if origin_date_in_part_overtext?(assoc, ctx)
      quals << 'Guest Content' if ctx[:in_guest_layer]
      ndp_entry(value, quals, ctx[:para_locus], assoc, assoc.dig('iso', 'not_before').to_s.presence)
    end

    # Part label appears only on an origin date reached within a part's overtext layer.
    def origin_date_in_part_overtext?(assoc, ctx)
      assoc.dig('type', 'id') == 'origin' && ctx[:in_ot_layer] && ctx[:part_label].to_s.present?
    end

    # Assemble one display entry, dropping blank pieces so no orphaned separators
    # or empty parentheses are produced. `seq` is stamped later by ndp_push.
    def ndp_entry(head, quals, locus, assoc, sort_key)
      parenthetical = quals.compact
      title = head.dup
      title << " (#{parenthetical.join(', ')})" if parenthetical.any?
      display = [title, locus.to_s.presence].compact.join(', ')

      {
        display: display,
        as_written: assoc['as_written'].to_s.presence,
        notes: ndp_notes(assoc['note']),
        sort_key: sort_key
      }
    end

    def ndp_notes(raw)
      Array(raw).map { |n| n.is_a?(Hash) ? n['value'].to_s : n.to_s }.map(&:strip).reject(&:blank?)
    end

    # Sort by the entry's key, keeping keyless entries after keyed ones and, in
    # both groups, falling back to order of appearance (seq) for ties.
    def ndp_sort(entries)
      entries.sort_by { |e| [e[:sort_key].present? ? 0 : 1, e[:sort_key].to_s, e[:seq]] }
    end
end
