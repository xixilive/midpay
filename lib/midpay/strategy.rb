module Midpay
  module Strategy

    class Options < ::Hashie::Mash; end

    class PaymentInfo
      require 'json'
      attr_accessor :pay, :raw_data, :extra, :success
      def initialize pay, &block
        @pay = pay
        @raw_data = {}
        @extra = {}
        @success = nil
        yield(self) if block_given?
      end

      def valid?
        !pay.to_s.empty? && raw_data.is_a?(::Hash) && !raw_data.empty?
      end

      def to_hash
        {
          :pay => pay,
          :raw_data => raw_data,
          :extra => extra,
          :success => success?
        }
      end

      def to_json
        to_hash.to_json
      end

      def success?
        !!success
      end
    end

    def self.included base
      base.extend ClassMethods
      Midpay[base.strategy_name.to_sym] = base
    end

    module ClassMethods
      def default_options
        @default_options ||= Options.new(name: self.strategy_name)
      end

      def default_arguments
        @default_arguments ||= Options.new
      end

      def option name, value = nil
        default_options[name] = value
      end

      def set name, value = nil
        default_arguments[name] = value
      end

      def strategy_name
        self.name.split("::").last.to_s.gsub(/(?!(^))([A-Z])/,'_\1\2').downcase
      end
    end

    attr_reader :app, :env, :options, :arguments

    # Usage
    # Strategy.new app, 'APP_KEY', 'APP_SECRET', &block
    # Strategy.new app, :app_key => 'APP_KEY', :app_secret => 'APP_SECRET', &block
    # Strategy.new app, :app_key => 'APP_KEY', :app_secret => 'APP_SECRET', :request_params_proc => PROC
    # Strategy.new app, 'APP_KEY', 'APP_SECRET', :request_params_proc => PROC
    def initialize app, *args, &block
      @app, @env, @options = app, nil, self.class.default_options.dup
      opts = args.last.is_a?(::Hash) ? args.pop : {}
      options.request_params_proc = block if block_given?
      options.app_key, options.app_secret = args.slice!(0,2)
      [:app_key, :app_secret, :request_params_proc].each do |k|
        options[k] ||= opts.delete(k) if opts[k]
      end
      @arguments = self.class.default_arguments.dup.merge(opts)
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @env = env;
      on_path?(callback_path) ? callback_call! : (on_path?(request_path) ? request_call! : app.call(env))
    end

    def root_path
      ::Midpay.config.root_path.to_s.sub(/\/$/,'')
    end

    def request_path
      path = options.request_path || "#{root_path}/#{options.name}"
      path.sub(/\/$/,'')
    end

    def callback_path
      path = options.callback_path || "#{root_path}/#{options.name}/callback"
      path.sub(/\/$/,'')
    end

    def current_path
      request.path_info.downcase.sub(/\/$/,'')
    end

    def on_path? path
      current_path.casecmp(path) == 0
    end

    def callback_url
      URI.join(request.url, callback_path).to_s
    end

    def request_call!
      log :info, "midpay request_call!"
      response = ::Rack::Response.new
      request_phase(response)
      response.finish
    end

    def request_data
      proc = options.request_params_proc
      @request_data ||= ::Midpay::SignableHash.new(proc.respond_to?(:call) ? proc.call(request.params.dup) : {})
    end

    def callback_call!
      log :info, "midpay callback_call!"
      pi = PaymentInfo.new(options.name)
      callback_phase(pi)
      raise ::Midpay::Errors::InvalidPaymentInfo.new unless pi.valid?
      env['midpay.strategy'] = self
      env['midpay.callback'] = pi
      app.call(env)
    end

    def request
      @request ||= ::Rack::Request.new(@env)
    end

    def request_params
      @request_params ||= ::Midpay::SignableHash.new(@request.params || {})
    end

    def log(l ,msg)
      ::Midpay.logger.send(l, msg)
    end

    def request_phase(response); raise NotImplementedError.new; end
    def callback_phase; raise NotImplementedError.new; end
  end
end