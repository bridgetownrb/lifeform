# frozen_string_literal: true

require "phlex"
require "active_support/core_ext/string/output_safety"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Lifeform
  class Error < StandardError; end
end

if defined?(Bridgetown)
  # Check compatibility
  raise "The Lifeform support for Bridgetown requires v1.2 or newer" if Bridgetown::VERSION.to_f < 1.2

  Bridgetown.initializer :lifeform do |config|
    # no extra config at the moment
  end
end
