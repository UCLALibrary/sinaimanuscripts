module RightRailHelper
  # Builds the nav outline for the Full Description tab.
  # Returns an array of entries: { id:, label:, children: [...] }.
  # Anchor IDs must match those rendered by the content partials
  # (_tab_navigation, _parts_metadata, _item_entry, _paracontents_metadata,
  # _notes_on_manuscript_metadata).
  def full_description_nav_entries(document)
    ms_json = parse_manuscript_json(document)
    entries = []

    entries << { id: 'section-overview', label: 'Overview', children: [] }

    Array(ms_json['part']).each_with_index do |part, part_idx|
      entries << build_part_entry(part, part_idx)
    end

    if paracontents_present?(ms_json)
      entries << { id: 'section-paracontents', label: 'Paracontents', children: [] }
    end

    if notes_on_manuscript_present?(ms_json)
      entries << { id: 'section-notes-on-manuscript', label: 'Notes on the Manuscript', children: [] }
    end

    entries
  end

  # Parses captured tab-panel HTML, finds heading-like elements, ensures each
  # has a stable id, and returns [entries_tree, augmented_html_string].
  # Used by tabs other than Full Description that don't have a bespoke helper.
  def extract_nav_entries_from_html(html)
    return [[], html.to_s] if html.blank?

    fragment = Nokogiri::HTML.fragment(html.to_s)
    selectors = 'h2, h3, h4, .work-accordion__title--sinai'
    # Nodes (or descendants of nodes) marked data-nav-skip render on the page but
    # stay out of the nav: the section title, in-layer paracontent, item rubrics.
    headings = fragment.css(selectors).reject { |node| nav_skipped?(node) }
    return [[], fragment.to_html] if headings.empty?

    flat = headings.map.with_index { |node, idx| nav_entry_for(node, idx) }
    [nest_by_level(flat), fragment.to_html]
  end

  private

  # A heading is kept out of the nav when it (or an ancestor) carries data-nav-skip.
  def nav_skipped?(node)
    node.key?('data-nav-skip') || node.ancestors('[data-nav-skip]').any?
  end

  # Builds one flat nav entry for a heading node, assigning a stable anchor id and
  # a nesting level from the tag (h2 > h3 > h4 > accordion title).
  def nav_entry_for(node, idx)
    anchor_host = node
    # A work-accordion title's id belongs on its <details>/<div> wrapper.
    if node['class'].to_s.include?('work-accordion__title--sinai')
      anchor_host = node.ancestors('.work-accordion--sinai').first || node
    end
    anchor_host['id'] ||= "section-auto-#{idx}-#{node.text.to_s.parameterize.first(40).presence || 'section'}"
    level = case node.name
            when 'h2' then 1
            when 'h3' then 2
            when 'h4' then 3
            else 4
            end
    { id: anchor_host['id'], label: node.text.to_s.strip, level: level, children: [] }
  end

  def nest_by_level(flat)
    root = []
    stack = [{ level: 0, children: root }]
    flat.each do |entry|
      stack.pop while stack.last[:level] >= entry[:level]
      stack.last[:children] << entry
      stack << entry
    end
    root.each { |entry| strip_level_keys(entry) }
    root
  end

  def strip_level_keys(entry)
    entry.delete(:level)
    entry[:children].each { |c| strip_level_keys(c) } if entry[:children].is_a?(Array)
  end


  def parse_manuscript_json(document)
    raw = document['manuscript_json_ts']
    return {} if raw.blank?

    JSON.parse(raw)
  rescue JSON::ParserError
    {}
  end

  def build_part_entry(part, part_idx)
    {
      id: "section-part-#{part_idx}",
      label: part_header_label(part),
      children: build_item_entries(part, part_idx)
    }
  end

  # Mirrors _parts_metadata.html.erb header assembly.
  def part_header_label(part)
    part_label = part['label'].to_s
    part_locus = part['locus'].to_s
    header_date = first_origin_date(part)

    parts = [part_label]
    parts << "(#{header_date})" if header_date.present?
    label = parts.join(' ')
    label = "#{label}, #{part_locus}" if part_locus.present?
    label
  end

  def first_origin_date(part)
    candidates = Array(part['assoc_date'])
    Array(part['ot_layer']).each do |ot_layer|
      lr = ot_layer['layer_record'] || {}
      candidates += Array(lr['assoc_date'])
      Array(lr['para']).each do |pa|
        candidates += Array(pa['assoc_date'])
      end
    end
    origin = candidates.find { |d| d.dig('type', 'id') == 'origin' && d['value'].present? }
    origin ? origin['value'].to_s : ''
  end

  def build_item_entries(part, part_idx)
    items = []
    Array(part['ot_layer']).each do |ot_layer|
      Array(ot_layer.dig('layer_record', 'text_unit')).each do |tu|
        items << tu
      end
    end

    items.each_with_index.map do |tu, idx|
      item_num = idx + 1
      {
        id: "section-part-#{part_idx}-item-#{item_num}",
        label: item_header_label(tu, item_num),
        children: build_work_entries(tu, part_idx, item_num)
      }
    end
  end

  # Mirrors _item_entry.html.erb header assembly.
  def item_header_label(tu, item_num)
    rec = tu['text_unit_record'] || {}
    tu_locus = tu['locus'].to_s.presence || rec['locus'].to_s.presence
    langs = Array(rec['lang']).map { |l| l['label'] }.compact
    lang_str = langs.any? ? "(#{langs.join(', ')})" : nil

    header = "Item #{item_num}"
    header = "#{header}, #{tu_locus}" if tu_locus.present?
    header = "#{header} #{lang_str}" if lang_str.present?
    header
  end

  def build_work_entries(tu, part_idx, item_num)
    rec = tu['text_unit_record'] || {}
    Array(rec['work_wit']).each_with_index.map do |ww, wi|
      {
        id: "section-part-#{part_idx}-item-#{item_num}-work-#{wi}",
        label: work_header_label(ww),
        children: []
      }
    end
  end

  # Mirrors _item_entry.html.erb work header assembly.
  def work_header_label(ww)
    work = ww['work'] || {}
    title = work['desc_title'].to_s.presence || work['pref_title'].to_s.presence || 'Untitled'
    cpg = Array(work['refno']).find { |r| r['source'].to_s.downcase == 'cpg' }
    refno_str = cpg ? "(#{cpg['source'].to_s.strip} #{cpg['idno']})".strip : nil
    locus = ww['locus'].to_s.presence

    parts = [title]
    parts << refno_str if refno_str.present?
    header = parts.join(' ')
    header = "#{header}, #{locus}" if locus.present?
    header
  end

  def paracontents_present?(ms_json)
    collected = []
    Array(ms_json['part']).each do |part|
      Array(part['ot_layer']).each do |ot_layer|
        Array(ot_layer.dig('layer_record', 'para')).each { |pa| collected << pa }
      end
    end
    collected.any? { |pa| %w[history misc].include?(pa.dig('type', 'id')) }
  end

  def notes_on_manuscript_present?(ms_json)
    collected = []
    Array(ms_json['note']).each { |n| collected << n }
    Array(ms_json['part']).each do |part|
      Array(part['note']).each { |n| collected << n }
    end
    collected.any?
  end
end
