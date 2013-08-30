module Midpay
  module HashExtensions
    require 'hashie/version'

    def self.included base
      if ::Hashie::VERSION.to_i >= 2
        base.send :include, ::Hashie::Extensions::MergeInitializer
        base.send :include, ::Hashie::Extensions::StringifyKeys
        base.send :include, ::Hashie::Extensions::SymbolizeKeys
        base.send :include, ::Hashie::Extensions::IndifferentAccess
      else

        require 'midpay/hash/merge_initializer'
        require 'midpay/hash/indifferent_access'
        require 'midpay/hash/key_conversion'

        base.send :include, ::Midpay::HashExtensions::MergeInitializer
        base.send :include, ::Midpay::HashExtensions::IndifferentAccess
        base.send :include, ::Midpay::HashExtensions::StringifyKeys
        base.send :include, ::Midpay::HashExtensions::SymbolizeKeys
      end
      
    end
  end
end