# frozen_string_literal: true

module ActionHooks
  class SourceNotDefinedError < StandardError; end

  class Source
    attr_accessor :name, :worker, :verify_signature, :allowed_ips

    def initialize(name)
      @name = name
      @verify_signature = ->(_request) { true }
      @allowed_ips = []
    end
  end

  class Configuration
    def initialize
      @sources = {}
    end

    def add_source(name)
      source = Source.new(name)
      yield(source) if block_given?
      @sources[name.to_sym] = source
    end

    def source(name)
      @sources.fetch(name.to_sym)
    rescue KeyError
      raise SourceNotDefinedError, "Source :#{name} is not defined in ActionHooks configuration"
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
