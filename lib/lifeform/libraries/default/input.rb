# frozen_string_literal: true

module Lifeform
  module Libraries
    class Default
      class Input
        attr_reader :form, :field_definition, :attributes

        INPUT_TAG = :input
        WRAPPER_TAG = :form_field

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

          attributes[:value] ||= value_for_model if form.model
          attributes[:name] = "#{model_name}[#{attributes[:name]}]" if @model
          attributes[:id] ||= attributes[:name].parameterize(separator: "_")
          @label = handle_labels if attributes[:label]
        end

        def model_name
          return @model.to_model.model_name.param_key if @model.respond_to?(:to_model)

          # Or just use basic underscore
          @model.class.name.underscore.tr("/", "_")
        end

        def value_for_model
          @model.send(attributes[:name])
        end

        def handle_labels
          Papercraft.html do |label_text, name|
            label label_text, for: name
          end.render(
            attributes[:label].to_s,
            (attributes[:id] || attributes[:name]).to_s
          ).tap do
            @attributes = attributes.filter_map { |k, v| [k, v] unless k == :label }.to_h
          end
        end

        def render_in(view_context)
          @view_context = view_context
          template
        end

        def template
          Papercraft.html do |wrapper_tag:, input_tag:, attributes:, field_type:, field_label:|
            field_body = proc {
              emit(field_label) if field_label
              send input_tag, type: field_type, **attributes
            }
            next field_body.call unless wrapper_tag

            send wrapper_tag, name: attributes[:name], &field_body
          end.render(
            wrapper_tag: self.class.const_get(:WRAPPER_TAG),
            input_tag: self.class.const_get(:INPUT_TAG),
            attributes: attributes,
            field_type: @field_type,
            field_label: @label
          )
        end
      end
    end
  end
end
