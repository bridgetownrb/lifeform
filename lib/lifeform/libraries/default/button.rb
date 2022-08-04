# frozen_string_literal: true

module Lifeform
  module Libraries
    class Default
      class Button < Phlex::Component
        attr_reader :form, :field_definition, :attributes

        WRAPPER_TAG = :form_button
        BUTTON_TAG = :button

        register_element WRAPPER_TAG

        def initialize(form, field_definition, **attributes)
          @form = form
          @field_definition = field_definition
          @attributes = Lifeform::Form.parameters_to_attributes(field_definition.parameters).merge(attributes)
          @if = @attributes.delete(:if)
          @label = @attributes.delete(:label) || "Unlabeled Button"
          @attributes[:type] ||= "button"
        end

        def internal_template
          return if !@if.nil? && !@if

          wrapper_tag = self.class.const_get(:WRAPPER_TAG)
          button_tag = self.class.const_get(:BUTTON_TAG)
          field_data = {
            label: EscapeUtils.unescape_html(@label.to_s),
            content: @content && @view_context.capture(&@content)
          }

          field_body = proc {
            send(button_tag, **@attributes) do
              _raw field_data[:content] || field_data[:label]
            end
          }
          return field_body.call unless wrapper_tag

          send wrapper_tag, name: @attributes[:name], &field_body
        end

        def template
          internal_template # let subclasses use this too
        end
      end
    end
  end
end
