# encoding:utf-8
require 'rspec'
require 'rspec/autorun'
require 'midpay'
require 'rack/test'

if %W[on yes true 1].include?(ENV['RCOV'])
  require 'simplecov'
  require 'simplecov-rcov'
  class SimpleCov::Formatter::MergedFormatter
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      SimpleCov::Formatter::RcovFormatter.new.format(result)
    end
  end
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

  SimpleCov.start "test_frameworks" do 
    #add_filter ''
  end
end

Dir["spec/support/**/*.rb"].each { |f| require File.expand_path(f) }

RSpec.configure do |c|
  c.before(:suite) do
    
  end

  c.before(:each) do
    
  end

  c.after(:suite) do
    
  end
end