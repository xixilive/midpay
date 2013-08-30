module Midpay
  class SignableHash < ::Hash
    require 'digest'

    include ::Midpay::HashExtensions

    def sign algorithm, &block
      data = yield(self.dup)
      begin
        algorithm_const(algorithm).send(:hexdigest, data)
      rescue
        nil
      end
    end

    def sign! key, algorithm, &block
      self[key] = self.sign(algorithm, &block)
      self
    end

    def to_query
      collect{|k,v| "#{::URI.encode_www_form_component(k.to_s)}=#{::URI.encode_www_form_component(v.to_s)}" }.sort.join("&")
    end

    def merge_if! hash
      hash.each do |i|
        self[i[0]] = i[1] unless self.key?(i[0])
      end if hash.respond_to?(:each)
      self
    end

    def algorithm_const algorithm
      algorithm = self[algorithm] if key?(algorithm) && self[algorithm]
      begin
        ::Digest.const_get(algorithm.to_s.upcase)
      rescue
        #
      end
    end

  end
end