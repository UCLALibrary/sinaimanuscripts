# frozen_string_literal: true
module Sinai
  class ReferencesMetadataPresenter < BaseMetadataPresenter
    self.config_file = 'metadata-sinai/references_metadata.yml'

    def references_terms
      fields_to_render_by_config_keys
    end
  end
end
