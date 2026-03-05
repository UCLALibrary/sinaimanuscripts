# frozen_string_literal: true

module Blacklight
  module Document
    # Render the thumbnail for the document
    class ThumbnailComponent < Blacklight::Component
      with_collection_parameter :presenter

      # @param [Blacklight::DocumentPresenter] presenter
      # @param [Integer] counter
      # @param [Hash] image_options options for the thumbnail presenter's image tag
      def initialize(presenter: nil, document: nil, counter:, gallery_view: false, image_options: {})
        @presenter = presenter
        @document = presenter&.document || document
        @counter = counter
        @image_options = { alt: '' }.merge(image_options)
        @gallery_view = gallery_view
      end

      def render?
        presenter.thumbnail.exists?
      end

      def use_thumbnail_tag_behavior?
        !presenter.thumbnail.instance_of?(Blacklight::ThumbnailPresenter)
      end

      def warn_about_deprecated_behavior
        Deprecation.warn(Blacklight::Document::ThumbnailComponent, 'Detected as custom thumbnail presenter; make sure it has a #render method that returns just the thumbnail image tag')
      end

      def gallery_view?
        @gallery_view
      end

      def presenter
        @presenter ||= helpers.document_presenter(@document)
      end
    end
  end
end
