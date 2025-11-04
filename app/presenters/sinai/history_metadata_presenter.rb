# frozen_string_literal: true
module Sinai
  class HistoryMetadataPresenter < BaseMetadataPresenter
    self.config_file = 'metadata-sinai/history_metadata.yml'

    def history_terms
      fields_to_render_by_config_keys
    end
  end
end
