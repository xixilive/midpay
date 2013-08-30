lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "midpay/version"
require 'logger'
require 'singleton'
require 'rack'
require 'uri'
require 'hashie'

module Midpay
  class << self
    def strategies
      @@strategies ||= {}
    end

    def []= name, value
      strategies[name.to_sym] = value
    end

    def [] name
      strategies[name.to_sym]
    end
  end

  class Configuration
    include Singleton

    attr_accessor :root_path, :logger

    def initialize
      @root_path = "/midpay"
      @logger = ::Logger.new(STDOUT)
      logger.progname = "midpay"
    end
  end

  def self.config
    Configuration.instance
  end

  def self.logger
    config.logger
  end

  def self.configure
    yield config
  end

  autoload :Builder, 'midpay/builder.rb'
  autoload :Strategy, "midpay/strategy.rb"
  autoload :HashExtensions, "midpay/hash_extensions.rb"
  autoload :SignableHash, "midpay/signable_hash.rb"
  
  module Errors
    class InvalidPaymentInfo < ::StandardError; end
    class InvalidSignature < ::StandardError; end
  end

end