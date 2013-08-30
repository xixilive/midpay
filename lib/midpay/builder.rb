module Midpay
  class Builder < ::Rack::Builder
    
    def midpay klass, *args, &block
      raise "Invalid Middleware" unless (middleware = klass.is_a?(Class) ? klass : Midpay[klass])
      use middleware, *args, &block
    end

    def call(env)
      to_app.call(env)
    end

  end
end