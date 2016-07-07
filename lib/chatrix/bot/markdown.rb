# frozen_string_literal: true

require 'redcarpet'

module Chatrix
  class Bot
    # Contains various markdown-related helpers.
    module Markdown
      # Custom renderer class for Redcarpet.
      class Renderer < Redcarpet::Render::HTML
        # Pattern matching the wrapping paragraph tag and its content.
        WRAP = %r{\A<p>(.*)</p>\n\z}m

        # Pattern matching places in the generated HTML where a paragraph
        # break happens.
        P_BREAKS = %r{</p>\n*<p>}

        # Initializes a new Renderer instance.
        # @param exts [Hash] A hash of options for the renderer.
        def initialize(exts = {})
          super({
            no_images: true, no_styles: true, hard_wrap: true
          }.merge(exts))
        end

        # We do not want or need paragraph tags when sending to matrix,
        # this method takes care of stripping that out of the final
        # rendered text.
        # @param (see Redcarpet::Render::HTML#postprocess)
        # @return (see Redcarpet::Render::HTML#postprocess)
        def postprocess(document)
          WRAP.match(document)[1].gsub(P_BREAKS, '<br><br>').delete "\n"
        rescue
          document
        end
      end

      def self.markdown
        @markdown ||= Redcarpet::Markdown.new(
          Renderer,
          no_intra_emphasis: true, fenced_code_blocks: true,
          strikethrough: true, superscript: true, underline: true,
          highlight: true
        )
      end

      def self.render(text)
        markdown.render text
      end
    end
  end
end
