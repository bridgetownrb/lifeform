# frozen_string_literal: true

module Lifeform
  module Libraries
    class Default
      class Input < Phlex::Component
        attr_reader :form, :field_definition, :attributes

        WRAPPER_TAG = :form_field
        INPUT_TAG = :input

        register_element WRAPPER_TAG

        def initialize(form, field_definition, **attributes)
          @form = form
          @field_definition = field_definition
          @attributes = Lifeform::Form.parameters_to_attributes(field_definition.parameters).merge(attributes)
          @field_type = field_definition.type

          verify_attributes
        end

        def verify_attributes # rubocop:disable Metrics
          @model = attributes.delete(:model)
          @model = form.model if form.model && @model.nil?

          @if = attributes.delete(:if)
          attributes[:value] ||= value_for_model if form.model
          attributes[:name] = "#{model_name}[#{attributes[:name]}]" if @model
          attributes[:id] ||= attributes[:name].parameterize(separator: "_")
          @label = handle_labels if attributes[:label]
        end

        def model_name
          name_of_model = @form.class.name_of_model(@model)

          form.parent_name ? "#{form.parent_name}[#{name_of_model}]" : name_of_model
        end

        def value_for_model
          @model.send(attributes[:name])
        end

        def handle_labels
          label_text = attributes[:label].to_s
          label_name = (attributes[:id] || attributes[:name]).to_s

          @attributes = attributes.filter_map { |k, v| [k, v] unless k == :label }.to_h

          proc {
            label(for: label_name) { _raw label_text }
          }
        end

        def internal_template # rubocop:disable Metrics/AbcSize
          return if !@if.nil? && !@if

          wrapper_tag = self.class.const_get(:WRAPPER_TAG)
          input_tag = self.class.const_get(:INPUT_TAG)
          field_data = {
            content: @content && @view_context.capture(&@content)
          }

          field_body = proc {
            @label&.()
            send input_tag, type: @field_type.to_s, **@attributes
            _raw field_data[:content] if field_data[:content]
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
