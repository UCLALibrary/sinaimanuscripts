# frozen_string_literal: true
require 'rails_autolink'

module ApplicationHelper
  include ERB::Util # provides html_escape

  # Uses Rails auto_link to add links to fields
  #
  # @param field [String,Hash] string to format and escape, or a hash as per helper_method
  # @option field [SolrDocument] :document
  # @option field [String] :field name of the solr field
  # @option field [Blacklight::Configuration::IndexField, Blacklight::Configuration::ShowField] :config
  # @option field [Array] :value array of values for the field
  # @param show_link [Boolean]
  # @return [ActiveSupport::SafeBuffer]
  def iconify_auto_link(field, show_link = true)
    if field.is_a? Hash
      options = field[:config].separator_options || {}
      text = field[:value].to_sentence(options)
    else
      text = field
    end
    # this block is only executed when a link is inserted;
    # if we pass text containing no links, it just returns text.
    auto_link(html_escape(text)) do |value|
      "<span class='fa fa-external-link'></span>#{('&nbsp;' + value) if show_link}"
    end
  end

  # Renders discrete metadata values one per line with vertical spacing between
  # them (Figma NOP-165). Replaces bare `<br>` joins so separate DB values are
  # visually distinct from wrapped text. `tight: true` -> 4px (origin dates); else 12px.
  #
  # Values are expected to be html-safe already (callers pass `h(...)` / `link_to`);
  # `tag.div(v)` preserves `safe_join`'s escaping semantics.
  #
  # @param values [Array] pre-rendered value strings/links, one per line
  # @param tight [Boolean] use the tighter 4px gap (origin/assoc_date stacks)
  # @return [ActiveSupport::SafeBuffer, nil]
  def stacked_metadata_values(values, tight: false)
    values = Array(values).reject { |v| v.to_s.strip.empty? }
    return if values.empty?

    css = 'metadata-value-stack--sinai'
    css += ' metadata-value-stack--tight--sinai' if tight
    tag.div(class: css) { safe_join(values.map { |v| tag.div(v) }) }
  end
end
