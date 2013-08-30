module Midpay
  module HashExtensions
    module MergeInitializer
      def initialize(hash = {}, default = nil, &block)
        default ? super(default) : super(&block)
        hash.each do |key, value|
          self[key] = value
        end
      end
    end
  end
end