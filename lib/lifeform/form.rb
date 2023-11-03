# frozen_string_literal: true

require "hash_with_dot_access"

module Lifeform
  FieldDefinition = Struct.new(:type, :library, :parameters)

  # A form object which stores field definitions and can be rendered as a component
  class Form # rubocop:todo Metrics/ClassLength
    include Lifeform::Renderable
    extend Sequel::Inflections

    MODEL_PATH_HELPER = :polymorphic_path

    class << self
      def inherited(subclass)
        super
        subclass.library library
      end

      # Helper to point to `I18n.t` method
      def t(...) = I18n.t(...)

      def configuration = @configuration ||= HashWithDotAccess::Hash.new

      # @param block [Proc, nil]
      # @return [Hash<Symbol, FieldDefinition>]
      def fields(&block)
        @fields ||= {}
        @fields_setup_block = block if block_given?

        @fields
      end

      def initialize_field_definitions!
        return unless @fields_setup_block

        @fields_setup_block.(configuration)
      end

      def subforms = @subforms ||= {}

      def field(name, type: :text, library: self.library, **parameters)
        parameters[:name] = name.to_sym
        fields[name] = FieldDefinition.new(type, Libraries.const_get(camelize(library)), parameters)
      end

      def subform(name, klass, parent_name: nil)
        subforms[name.to_sym] = { class: klass, parent_name: parent_name }
      end

      def library(library_name = nil)
        @library = library_name.to_sym if library_name
        @library ||= :default
      end

      def process_value(key, value)
        return value if key == :if

        case value
        when TrueClass
          key.to_s
        when FalseClass
          nil
        when Symbol, Integer
          value.to_s
        else
          value
        end
      end

      # @param kwargs [Hash]
      def parameters_to_attributes(kwargs)
        attributes = {}
        kwargs.each do |key, value|
          case value
          when Hash
            value.each do |inner_key, inner_value|
              attributes[:"#{key}_#{inner_key}"] = process_value(inner_key, inner_value)
            end
          else
            attributes[key] = process_value(key, value) unless value.nil?
          end
        end

        attributes
      end

      def name_of_model(model)
        return "" if model.nil?

        if model.respond_to?(:to_model)
          model.to_model.model_name.param_key
        else
          # Or just use basic underscore
          underscore(model.class.name).tr("/", "_")
        end
      end

      # @return [Array<Symbol>]
      def param_keys = fields.keys

      # @return [Array<String>]
      def param_string_keys = fields.keys.map(&:to_s)
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
      @library = Libraries.const_get(self.class.send(:camelize, @library_name))
      @subform_instances = {}

      self.class.initialize_field_definitions!

      @method = parameters[:method] ||= model.respond_to?(:persisted?) && model.persisted? ? :patch : :post
      parameters[:accept_charset] ||= "UTF-8"
      verify_method
    end

    def verify_method
      return if %w[get post].include?(parameters[:method].to_s.downcase)

      method_value = @parameters[:method].to_s.downcase

      @method_tag = -> {
        <<~HTML
          <input type="hidden" name="_method" #{attribute_segment :value, method_value} autocomplete="off">
        HTML
      }

      parameters[:method] = :post
    end

    def add_authenticity_token # rubocop:disable Metrics/AbcSize
      if helpers.respond_to?(:token_tag, true) # Rails
        helpers.send(:token_tag, nil, form_options: {
                       action: parameters[:action].to_s,
                       method: parameters[:method].to_s.downcase
                     })
      elsif helpers.respond_to?(:csrf_tag, true) # Roda
        helpers.send(:csrf_tag, parameters[:action].to_s, @method.to_s)
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

    def template(&block) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      form_tag = library::FORM_TAG
      parameters[:action] ||= url || (model ? helpers.send(self.class.const_get(:MODEL_PATH_HELPER), model) : nil)

      html -> {
        <<~HTML
          <#{form_tag}#{attrs -> { attributes }}>
            #{add_authenticity_token unless parameters[:method].to_s.downcase == "get"}
            #{@method_tag&.() || ""}
            #{block ? capture(self, &block) : auto_render_fields}
          </#{form_tag}>
        HTML
      }
    end

    def auto_render_fields = html_map(self.class.fields) { |k, _v| render(field(k)) }

    def render(field_object)
      field_object.render_in(helpers || self)
    end
  end
end
