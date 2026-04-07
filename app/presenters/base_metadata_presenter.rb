# frozen_string_literal: true
class BaseMetadataPresenter
  class << self
    attr_accessor :config_file
  end

  attr_reader :document, :config

  def initialize(document:)
    @document = document
    @config = YAML.safe_load(File.open(Rails.root.join('config', self.class.config_file)))
  end

  def fields_to_render_by_config_keys
    result = fields_to_render_by_keys(@config.keys)
    # Re-sort by YAML config order (not CatalogController order)
    ordered = {}
    @config.keys.each do |key|
      ordered[key] = result[key] if result.key?(key)
    end
    ordered
  end

  def fields_to_render_by_keys(keys)
    result = {}
    @document.fields_to_render
              .each do |field_name, field_config, _field_presenter|
                result[field_name] = field_config if keys.include?(field_name)
              end
    result
  end
end
