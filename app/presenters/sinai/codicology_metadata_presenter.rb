# frozen_string_literal: true
module Sinai
  class CodicologyMetadataPresenter < BaseMetadataPresenter
    self.config_file = 'metadata-sinai/codicology_metadata.yml'

    def codicology_terms
      fields_to_render_by_config_keys
    end
  end
end
