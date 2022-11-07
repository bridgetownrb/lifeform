# frozen_string_literal: true

module Lifeform
  module Libraries
    class Shoelace
      class Button < Default::Button
        BUTTON_TAG = :sl_button

        register_element BUTTON_TAG
      end
    end
  end
end
