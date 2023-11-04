# frozen_string_literal: true

require "serbea/helpers" # primarily just for HTML safety polyfill
require "serbea/pipeline"
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Lifeform
  class Error < StandardError; end
end

if defined?(Bridgetown)
  # Check compatibility
  raise "The Lifeform support for Bridgetown requires v1.2 or newer" if Bridgetown::VERSION.to_f < 1.2

  Bridgetown.initializer :lifeform do # |config|
  end
end
