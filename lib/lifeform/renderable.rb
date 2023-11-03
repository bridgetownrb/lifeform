# frozen_string_literal: true

module Lifeform
  module Renderable
    include Lifeform::Helpers

    def attrs(callback)
      attrs_string = attributes_from_options(callback.() || {})

      attrs_string = " #{attrs_string}" unless attrs_string.blank?

      attrs_string
    end

    def tag(tag, content, **options)
      "<#{tag}#{attrs -> { options }}>#{text -> { content }}</#{tag}>"
    end

    def render_in(view_context, &block)
      @_view_context = view_context
      template(&block)
    end

    def helpers
      @_view_context
    end

    def capture(*args, &block)
      helpers ? helpers.capture(*args, &block) : yield(*args)
    end
  end
end
