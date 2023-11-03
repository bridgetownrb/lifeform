# frozen_string_literal: true

module Lifeform
  module Libraries
    class Default
      class Input
        include Lifeform::Renderable

        attr_reader :form, :field_definition, :attributes

        WRAPPER_TAG = :form_field
        INPUT_TAG = :input

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
          # TODO: validate if this is enough
          attributes[:id] ||= attributes[:name].tr("[]", "_").gsub("__", "_").chomp("_") if attributes[:name]
          @label = handle_labels if attributes[:label]
        end

        def model_name
          name_of_model = @form.class.name_of_model(@model)

          form.parent_name ? "#{form.parent_name}[#{name_of_model}]" : name_of_model
        end

        def value_for_model = @model.send(attributes[:name])

        def handle_labels # rubocop:disable Metrics/AbcSize
          label_text = attributes[:label].is_a?(Proc) ? attributes[:label].pipe : attributes[:label]
          label_name = (attributes[:id] || attributes[:name]).to_s

          @attributes = attributes.filter_map { |k, v| [k, v] unless k == :label }.to_h

          -> {
            <<~HTML
              <label #{attribute_segment :for, label_name}>#{text -> { label_text }}</label>
            HTML
          }
        end

        def template(&block) # rubocop:disable Metrics/AbcSize
          return "" if !@if.nil? && !@if

          wrapper_tag = dashed self.class.const_get(:WRAPPER_TAG)
          input_tag = dashed self.class.const_get(:INPUT_TAG)
          closing_tag = input_tag != "input"

          field_body = html -> {
            <<~HTML
              #{html(@label || -> {}).to_s.strip}
              <#{input_tag}#{attrs -> { { type: @field_type.to_s, **@attributes } }}>#{"</#{input_tag}>" if closing_tag}
              #{html -> { capture(self, &block) } if block}
            HTML
          }

          return field_body unless wrapper_tag

          html -> {
            <<~HTML
              <#{wrapper_tag}#{attrs -> { { name: @attributes[:name] } }}>#{field_body.to_s.strip}</#{wrapper_tag}>
            HTML
          }
        end
      end
    end
  end
end
