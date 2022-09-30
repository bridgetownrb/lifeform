# frozen_string_literal: true

require "phlex"
require "active_support/core_ext/string/output_safety"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Lifeform
  class Error < StandardError; end
end
