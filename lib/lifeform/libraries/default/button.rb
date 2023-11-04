# frozen_string_literal: true

module Lifeform
  module Libraries
    class Default
      class Button
        include Lifeform::Renderable

        attr_reader :form, :field_definition, :attributes

        WRAPPER_TAG = :form_button
        BUTTON_TAG = :button

        def initialize(form, field_definition, **attributes)
          @form = form
          @field_definition = field_definition
          @attributes = Lifeform::Form.parameters_to_attributes(field_definition.parameters).merge(attributes)
          @if = @attributes.delete(:if)
          @label = @attributes.delete(:label) || "Unlabeled Button"
          @attributes[:type] ||= "button"
        end

        def template(&block)
          return "" if !@if.nil? && !@if

          wrapper_tag = dashed self.class.const_get(:WRAPPER_TAG)
          button_tag = dashed self.class.const_get(:BUTTON_TAG)

          label_text = block ? capture(self, &block) : @label.is_a?(Proc) ? @label.pipe : @label # rubocop:disable Style/NestedTernaryOperator

          field_body = html -> {
            <<~HTML # rubocop:disable Bridgetown/HTMLEscapedHeredoc
              <#{button_tag}#{html_attributes @attributes, prefix_space: true}>#{text -> { label_text }}</#{button_tag}>
            HTML
          }

          return field_body unless wrapper_tag

          html -> {
            <<~HTML # rubocop:disable Bridgetown/HTMLEscapedHeredoc
              <#{wrapper_tag}#{html_attributes({ name: @attributes[:name] }, prefix_space: true)}>#{field_body}</#{wrapper_tag}>
            HTML
          }
        end
      end
    end
  end
end
