# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "lifeform"

require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new({ color: true })

require "rails-dom-testing"
