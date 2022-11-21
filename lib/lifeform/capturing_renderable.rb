# frozen_string_literal: true

module Lifeform
  module CapturingRenderable
    # NOTE: the previous `with_output_buffer` stuff is for some reason incompatible with Serbea.
    # So we'll use a simpler capture.
    def render_in(view_context, &block)
      if block
        call(view_context: view_context) do |*args, **kwargs|
          unsafe_raw(view_context.capture(*args, **kwargs, &block))
        end.html_safe
      else
        call(view_context: view_context).html_safe
      end
    end
  end
end
