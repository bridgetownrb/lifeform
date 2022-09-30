module Lifeform
  class FormView < Phlex::View
    def initialize(form_tag:, attributes:, method_tag:, form_contents:)
      @form_tag, @attributes, @method_tag, @form_contents = form_tag, attributes, method_tag, form_contents
    end

    def template
      send(@form_tag, **@attributes) do
        raw @method_tag&.() || ""
        raw @form_contents
      end
    end
  end
end
