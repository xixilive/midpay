require 'spec_helper'

class TestStrategy
  include Midpay::Strategy

  option :name, "test"

  def request_phase response
    response.write("You are being redirected to /?return_url=#{request_data[:return_url]}&callback=#{callback_url}")
  end

  def callback_phase pi
    pi.raw_data = request.params
    pi.success = true
  end
end

describe TestStrategy do
  include Rack::Test::Methods

  let(:request_params_proc){
    Proc.new do |params| 
      {
        :return_url =>'/return'
      }
    end
  }

  let(:inner_app){
    lambda {|env| [200, {'Content-Type' => 'text/html'}, ['body']] }
  }

  let(:app){
    TestStrategy.new(inner_app, :app_key => "APPKEY", :app_secret => "APPSECRET", :request_params_proc => request_params_proc)
  }

  it "on request phase" do
    get '/midpay/test'
    expect(last_response.body).to eq("You are being redirected to /?return_url=/return&callback=http://example.org/midpay/test/callback")
  end

  it "on callback_phase" do
    get '/midpay/test/callback?success=1'
    expect(last_request.env['midpay.callback'].pay).to eq("test")
    expect(last_request.env['midpay.callback'].raw_data).to eq({"success" => "1"})
    expect(last_request.env['midpay.callback'].success?).to be_true
  end

  it 'out of midpay phases' do
    get '/'
    expect(last_response.body).to eq("body")
  end
end

describe Midpay::Strategy::Options do
  let(:options){
    Midpay::Strategy::Options.new :foo=>'foo', :bar=>'bar'
  }

  it 'indifferent access' do
    expect(options['bar']).to eq(options[:bar])
    options[:another] = 'another'
    expect(options['another']).to eq('another')
  end

  it 'method access' do
    expect(options.bar).to eq(options[:bar])
    options.another = 'another'
    expect(options[:another]).to eq('another')
  end
end

describe Midpay::Strategy::PaymentInfo do
  let(:pi){
    Midpay::Strategy::PaymentInfo.new('test'){|pi|
      pi.raw_data = {"foo"=>"bar"}
      pi.extra = {"extra"=>"data"}
      pi.success = true
    }
  }

  it 'should be valid given pay and raw_data are NOT blank' do
    expect(pi.valid?).to be_true
    expect(Midpay::Strategy::PaymentInfo.new('test').valid?).to be_false
  end

  it '#to_hash' do
    expect(pi.to_hash).to eq({pay: 'test', raw_data: {"foo"=>"bar"}, extra: {"extra"=>"data"}, success: true})
  end

  it '#to_json' do
    expect(pi.to_json).to eq('{"pay":"test","raw_data":{"foo":"bar"},"extra":{"extra":"data"},"success":true}')
  end

  it '#success?' do
    expect(pi.success?).to be_true
    expect(Midpay::Strategy::PaymentInfo.new('test').success?).to be_false
  end
end