# frozen_string_literal: true

module Lifeform
  module Libraries
    class Shoelace
      class Input < Default::Input
        INPUT_TAG = :sl_input

        register_element :sl_input

        # no-op
        def handle_labels; end

        def template
          internal_template
        end
      end
    end
  end
end
