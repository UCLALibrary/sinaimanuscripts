# frozen_string_literal: true
module Ursus
  class SinaiIndexCollectionPresenter < BaseMetadataPresenter
    self.config_file = 'metadata/sinai_index_collection.yml'

    def sinai_index_collection_terms
      fields_to_render_by_config_keys
    end
  end
end
