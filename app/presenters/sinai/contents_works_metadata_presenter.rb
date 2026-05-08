# frozen_string_literal: true
module Sinai
  class ContentsWorksMetadataPresenter < BaseMetadataPresenter
    self.config_file = 'metadata-sinai/contents_works_metadata.yml'

    def contents_terms
      fields_to_render_by_config_keys
    end
  end
end
