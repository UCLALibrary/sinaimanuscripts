# frozen_string_literal: true
module Sinai
  class OverviewMetadataPresenter < BaseMetadataPresenter
    self.config_file = 'metadata-sinai/overview_metadata.yml'

    def overview_terms
      fields_to_render_by_config_keys
    end
  end
end
