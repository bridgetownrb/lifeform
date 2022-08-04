# frozen_string_literal: true

module Lifeform
  module Libraries
    class Default
      class Button
        attr_reader :form, :field_definition, :attributes

        WRAPPER_TAG = :form_button
        BUTTON_TAG = :button

        def initialize(form, field_definition, **attributes)
          @form = form
          @field_definition = field_definition
          @attributes = Lifeform::Form.parameters_to_attributes(field_definition.parameters).merge(attributes)
          @if = @attributes.delete(:if)
          @label = @attributes.delete(:label) || "Unlabeled Button"
          @attributes[:type] ||= :button
        end

        def render_in(view_context, &block)
          @view_context = view_context
          @content = block
          return "" if !@if.nil? && !@if

          template
        end

        def template # rubocop:disable Metrics/AbcSize
          Papercraft.html do |wrapper_tag:, button_tag:, attributes:, field_data:|
            field_body = proc {
              send(button_tag, **attributes) do
                emit field_data[:content] || field_data[:label]
              end
            }
            next field_body.call unless wrapper_tag

            send wrapper_tag, name: attributes[:name], &field_body
          end.render(
            wrapper_tag: self.class.const_get(:WRAPPER_TAG),
            button_tag: self.class.const_get(:BUTTON_TAG),
            attributes: attributes,
            field_data: {
              label: EscapeUtils.unescape_html(@label.to_s),
              content: @content && @view_context.capture(&@content)
            }
          )
        end
      end
    end
  end
end
