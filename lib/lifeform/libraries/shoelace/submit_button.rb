# frozen_string_literal: true

module Lifeform
  module Libraries
    class Shoelace
      class SubmitButton < Button
        def initialize(form, field_definition, **attributes)
          attributes[:name] ||= "commit"
          attributes[:type] = "submit"

          super
        end
      end
    end
  end
end
