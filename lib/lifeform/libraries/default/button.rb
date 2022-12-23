# frozen_string_literal: true

module Lifeform
  module Libraries
    class Default
      class Button < Phlex::HTML
        using RefineProcToString
        include CapturingRenderable

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

        def template(&block)
          return if !@if.nil? && !@if

          wrapper_tag = self.class.const_get(:WRAPPER_TAG)
          button_tag = self.class.const_get(:BUTTON_TAG)

          field_body = proc {
            send(button_tag, **@attributes) do
              unsafe_raw(@label.to_s) unless block
              yield_content(&block)
            end
          }
          return field_body.() unless wrapper_tag

          send wrapper_tag, name: @attributes[:name], &field_body
        end
      end
    end
  end
end
