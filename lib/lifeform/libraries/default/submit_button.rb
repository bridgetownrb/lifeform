# frozen_string_literal: true

module Lifeform
  module Libraries
    class Default
      class SubmitButton < Button
        def initialize(form, field_definition, **attributes)
          attributes[:name] ||= "commit"
          attributes[:type] = "submit"

          super
        end

        def template
          internal_template
        end
      end
    end
  end
end
