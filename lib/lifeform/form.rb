# frozen_string_literal: true

require "active_support/core_ext/string/inflections"

module Lifeform
  FieldDefinition = Struct.new(:type, :library, :parameters)

  # A form object which stores field definitions and can be rendered as a component
  class Form # rubocop:todo Metrics/ClassLength
    MODEL_PATH_HELPER = :polymorphic_path

    class << self
      def inherited(subclass)
        super
        subclass.library library
      end

      # Helper to point to `I18n.t` method
      def t(...)
        I18n.t(...)
      end

      # @return [Hash<Symbol, FieldDefinition>]
      def fields
        @fields ||= {}
      end

      def subforms
        @subforms ||= {}
      end

      def field(name, type: :text, library: self.library, **parameters)
        parameters[:name] = name.to_sym
        fields[name] = FieldDefinition.new(type, Libraries.const_get(library.to_s.classify), parameters)
      end

      def subform(name, klass, parent_name: nil)
        subforms[name.to_sym] = { class: klass, parent_name: parent_name }
      end

      def library(library_name = nil)
        @library = library_name.to_sym if library_name
        @library ||= :default
      end

      def escape_value(value)
        case value
        when TrueClass, FalseClass
          value
        else
          EscapeUtils.escape_html(value.to_s)
        end
      end

      # @param kwargs [Hash]
      def parameters_to_attributes(kwargs)
        previous_value = EscapeUtils.html_secure
        EscapeUtils.html_secure = false

        attributes = {}
        kwargs.each do |key, value|
          case value
          when Hash
            value.each do |inner_key, inner_value|
              attributes[:"#{key}_#{inner_key}"] = escape_value(inner_value)
            end
          else
            attributes[key] = escape_value(value) unless value.nil?
          end
        end

        EscapeUtils.html_secure = previous_value

        attributes
      end

      def name_of_model(model)
        return "" if model.nil?

        if model.respond_to?(:to_model)
          model.to_model.model_name.param_key
        else
          # Or just use basic underscore
          model.class.name.underscore.tr("/", "_")
        end
      end
    end

    # @return [Object]
    attr_reader :model

    # @return [String]
    attr_reader :url

    # @return [Class<Libraries::Default>]
    attr_reader :library

    # @return [Hash]
    attr_reader :parameters

    # @return [Boolean]
    attr_reader :emit_form_tag

    # @return [Boolean]
    attr_reader :parent_name

    def initialize( # rubocop:disable Metrics/ParameterLists
      model = nil, url: nil, library: self.class.library, emit_form_tag: true, parent_name: nil, **parameters
    )
      @model, @url, @library_name, @parameters, @emit_form_tag, @parent_name =
        model, url, library, parameters, emit_form_tag, parent_name
      @library = Libraries.const_get(@library_name.to_s.classify)
      @subform_instances = {}

      parameters[:method] ||= model.respond_to?(:persisted?) && model.persisted? ? :patch : :post
      parameters[:accept_charset] ||= "UTF-8"
      verify_method
    end

    def verify_method
      return if %w[get post].include?(parameters[:method].to_s.downcase)

      @method_tag = Papercraft.html do |method_name|
        input type: "hidden", name: "_method", value: method_name, autocomplete: "off"
      end.render(parameters[:method].to_s.downcase)
      parameters[:method] = :post
    end

    def add_authenticity_token(view_context) # rubocop:disable Metrics/AbcSize
      if view_context.respond_to?(:token_tag, true) # Rails
        view_context.send(:token_tag, nil, form_options: {
                            action: parameters[:action].to_s,
                            method: parameters[:method].to_s.downcase
                          })
      elsif view_context.respond_to?(:csrf_tag, true) # Roda
        view_context.send(:csrf_tag, action: parameters[:action].to_s, method: parameters[:method].to_s)
      else
        raise Lifeform::Error, "Missing token tag helper. Override `add_authenticity_token' in your Form object"
      end
    end

    def attributes
      @attributes ||= self.class.parameters_to_attributes(parameters)
    end

    def field(name, **field_parameters)
      # @type [FieldDefinition]
      field_definition = self.class.fields[name.to_sym]
      # @type [Class<Libraries::Default>]
      field_library = field_definition.library
      field_library.object_for_field_definition(
        self, field_definition, self.class.parameters_to_attributes(field_parameters)
      )
    end

    def subform(name, model = nil)
      @subform_instances[name.to_sym] ||= self.class.subforms[name.to_sym][:class].new(
        model,
        emit_form_tag: false,
        parent_name: self.class.subforms[name.to_sym][:parent_name] || self.class.name_of_model(self.model)
      )
    end

    def render_in(view_context, &block) # rubocop:disable Metrics
      form_tag = library::FORM_TAG
      parameters[:action] ||= url || (model ? view_context.send(self.class.const_get(:MODEL_PATH_HELPER), model) : nil)

      content = if block
                  view_context.capture(self, &block)
                else
                  self.class.fields.map { |k, _v| field(k).render_in(self) }.join.then do |renderings|
                    renderings.respond_to?(:html_safe) ? renderings.html_safe : renderings
                  end
                end

      return content unless emit_form_tag

      content = add_authenticity_token(view_context) + content.to_s unless parameters[:method].to_s.downcase == "get"
      content = @method_tag + content.to_s if @method_tag

      # if @hidden_submit_button
      #   content += %(\n<button type="submit" style="position: absolute; left: -9999px"></button>).html_safe
      # end

      Papercraft.html do |attr|
        send(form_tag, **attr) { emit content }
      end.render(attributes)
    end
  end
end
