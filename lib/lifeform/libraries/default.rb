# frozen_string_literal: true

module Lifeform
  module Libraries
    class Default
      FORM_TAG = :form

      # @param form [LifeForm::Form]
      # @param field_definition [LifeForm::FieldDefinition]
      # @param attributes [Hash]
      # @return [Input]
      def self.object_for_field_definition(form, field_definition, attributes)
        type_classname = field_definition[:type].to_s.classify
        if const_defined?(type_classname)
          const_get(type_classname)
        else
          const_get(:Input)
        end.new(form, field_definition, **attributes)
      end
    end
  end
end
