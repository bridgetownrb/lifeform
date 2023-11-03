# frozen_string_literal: true

module Lifeform
  module Renderable
    include Lifeform::Helpers

    def render_in(view_context, &block)
      @_view_context = view_context
      template(&block).to_s.strip
    end

    def helpers
      @_view_context
    end

    def capture(*args, &block)
      helpers ? helpers.capture(*args, &block) : yield(*args)
    end
  end
end
