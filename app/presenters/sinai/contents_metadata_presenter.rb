# frozen_string_literal: true
module Sinai
  class ContentsMetadataPresenter < BaseMetadataPresenter
    self.config_file = 'metadata-sinai/contents_metadata.yml'

    def contents_terms
      fields_to_render_by_config_keys
    end
  end
end
