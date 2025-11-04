# frozen_string_literal: true
module Sinai
  class DecorationMetadataPresenter < BaseMetadataPresenter
    self.config_file = 'metadata-sinai/decoration_metadata.yml'

    def decoration_terms
      fields_to_render_by_config_keys
    end
  end
end
