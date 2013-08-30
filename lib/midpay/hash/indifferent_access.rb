module Midpay
  module HashExtensions
    module IndifferentAccess
      def self.included(base)
        base.class_eval do
          alias_method :regular_writer, :[]=
          alias_method :[]=, :indifferent_writer
          %w(default update fetch delete key? values_at).each do |m|
            alias_method "regular_#{m}", m
            alias_method m, "indifferent_#{m}"
          end

          %w(include? member? has_key?).each do |key_alias|
            alias_method key_alias, :indifferent_key?
          end
        end
      end

      def self.inject!(hash)
        (class << hash; self; end).send :include, IndifferentAccess
        hash.convert!
      end

      def self.inject(hash)
        inject!(hash.dup)
      end

      def convert_key(key)
        key.to_s
      end

      def convert!
        keys.each do |k|
          regular_writer convert_key(k), convert_value(self.regular_delete(k))
        end
        self
      end

      def convert_value(value)
        if hash_lacking_indifference?(value)
          IndifferentAccess.inject(value.dup)
        elsif value.is_a?(::Array)
          value.dup.replace(value.map { |e| convert_value(e) })
        else
          value
        end
      end
      
      def indifferent_default(key = nil)
        return self[convert_key(key)] if key?(key)
        regular_default(key)
      end

      def indifferent_update(other_hash)
        return regular_update(other_hash) if hash_with_indifference?(other_hash)
        other_hash.each_pair do |k,v|
          self[k] = v
        end
      end
      
      def indifferent_writer(key, value);  regular_writer convert_key(key), convert_value(value) end
      def indifferent_fetch(key, *args);   regular_fetch  convert_key(key), *args                end
      def indifferent_delete(key);         regular_delete convert_key(key)                       end
      def indifferent_key?(key);           regular_key?   convert_key(key)                       end
      def indifferent_values_at(*indices); indices.map{|i| self[i] }                             end

      def indifferent_access?; true end
      
      protected

      def hash_lacking_indifference?(other)
        other.is_a?(::Hash) &&
        !(other.respond_to?(:indifferent_access?) &&
          other.indifferent_access?)
      end

      def hash_with_indifference?(other)
        other.is_a?(::Hash) &&
        other.respond_to?(:indifferent_access?) &&
        other.indifferent_access?
      end
    end
  end
end