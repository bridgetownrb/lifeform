# frozen_string_literal: true

require "streamlined"
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Lifeform
  class Error < StandardError; end
end

if defined?(Bridgetown)
  Bridgetown.initializer :lifeform do |config|
    config.hook :authtown, :initialized do |rodauth|
      Lifeform::Form.rodauth = rodauth
    end
  end
end
