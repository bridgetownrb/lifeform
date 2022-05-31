# frozen_string_literal: true

require "test_helper"

class TestForm < Lifeform::Form
  field :occupation, label: "Your Job", id: "your-occupation", required: true
  field :age, library: :shoelace, label: "Your Age"
  field :noshow
end

class TestLifeform < Minitest::Test
  include Rails::Dom::Testing::Assertions

  attr_reader :document_root_element

  def document_root(root)
    @document_root_element = root.is_a?(Nokogiri::XML::Document) ? root : Nokogiri::HTML5(root)
  end

  def capture(*args)
    yield(*args)
  end

  def token_tag(*)
    ""
  end

  def test_that_it_has_a_version_number
    refute_nil ::Lifeform::VERSION
  end

  def test_form_library
    assert_equal :default, TestForm.library

    level1 = Class.new(TestForm) do
      library :shoelace
    end

    assert_equal :shoelace, level1.library

    level2 = Class.new(level1)

    assert_equal :shoelace, level2.library
  end

  def test_form_output
    form_object = TestForm.new(url: "/path")
    document_root(form_object.render_in(self) do |f|
      [
        f.field(:occupation).render_in(self),
        f.field(:age, value: 47).render_in(self),
        f.field(:noshow, if: false).render_in(self)
      ].join
    end)

    form = css_select("form").first
    # puts form.to_html

    assert_equal "/path", form[:action]
    assert_equal "post", form[:method]

    field_wrapper = form.css("form-field")[0]

    assert_equal "occupation", field_wrapper[:name]

    label = field_wrapper.at("label")

    assert_equal "your-occupation", label[:for]

    input = field_wrapper.at("input")

    assert_equal "your-occupation", input[:id]
    assert_equal "text", input[:type]
    assert_equal "occupation", input[:name]

    field_wrapper = form.css("form-field")[1]

    sl_input = field_wrapper.at("sl-input")
    refute field_wrapper.at("label")

    assert_equal "age", sl_input[:id]
    assert_equal "text", sl_input[:type]
    assert_equal "age", sl_input[:name]
    assert_equal "47", sl_input[:value]

    refute form.css("form-field")[2]
  end
end
