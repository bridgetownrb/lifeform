# frozen_string_literal: true

require "papercraft"
require "phlex"

module Phlex
  module RenderIn
    module Context
      def render_in(context)
        if block_given?
          content = nil
          context.with_output_buffer { content = yield }
          @_content = Phlex::Block.new(self) { _raw content }
        end

        call
      end
    end
  end
end

Phlex::Context.include(Phlex::RenderIn::Context)

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Lifeform
  class Error < StandardError; end
end
