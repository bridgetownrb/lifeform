# frozen_string_literal: true

module Lifeform
  module Helpers
    # Below is pretty much verbatim copied over from Bridgetown
    # TODO: extract both out to a shared gem

    # Create a set of attributes from a hash.
    #
    # @param options [Hash] key-value pairs of HTML attributes (or use keyword arguments)
    # @param prefix_space [Boolean] add a starting space if attributes are present,
    #   useful in tag builders
    # @return [String]
    def html_attributes(options = nil, prefix_space: false, **kwargs)
      options ||= kwargs
      segments = []
      options.each do |attr, option|
        attr = dashed(attr)
        if option.is_a?(Hash)
          option = option.transform_keys { |key| "#{attr}-#{dashed(key)}" }
          segments << html_attributes(option)
        else
          segments << attribute_segment(attr, option)
        end
      end
      segments.join(" ").then do |output|
        prefix_space && !output.empty? ? " #{output}" : output
      end
    end

    # Covert an underscored value into a dashed string.
    #
    # @example "foo_bar_baz" => "foo-bar-baz"
    #
    # @param value [String|Symbol]
    # @return [String]
    def dashed(value)
      value.to_s.tr("_", "-")
    end

    # Create an attribute segment for a tag.
    #
    # @param attr [String] the HTML attribute name
    # @param value [String] the attribute value
    # @return [String]
    def attribute_segment(attr, value)
      "#{attr}=#{value.to_s.encode(xml: :attr)}"
    end

    module PipeableProc
      include Serbea::Pipeline::Helper

      attr_accessor :pipe_block, :touched

      def pipe(&block)
        return super(self.(), &pipe_block) if pipe_block && !block

        self.touched = true
        return self unless block

        tap { _1.pipe_block = block }
      end

      def to_s
        return self.().to_s if touched

        super
      end

      def encode(...)
        to_s.encode(...)
      end
    end

    Proc.prepend(PipeableProc) unless defined?(Bridgetown::HTMLinRuby::PipeableProc)

    def text(callback)
      (callback.is_a?(Proc) ? html(callback) : callback).to_s.then do |str|
        next str if str.html_safe?

        str.encode(xml: :attr).gsub(%r{\A"|"\Z}, "")
      end
    end

    def html(callback)
      callback.pipe
    end

    def html_map(input, &callback)
      input.map(&callback).join
    end
  end
end
