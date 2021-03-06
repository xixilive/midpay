require 'spec_helper'

describe Midpay::SignableHash do
  let(:signable){ 
    Midpay::SignableHash.new({:foo => "Foo", :bar => "Bar", :url => "http://example.com"}, "default")
  }

  context '#sign' do
    it 'should return a signature-value that generated by algorithm' do
      #foo=Foo&bar=Bar&url=http://example.comSECRET MD5=cc2f3b4894dd34fe101df3d06184c386
      sign = signable.sign('MD5'){|hash| hash.to_a.collect{|i| i.join("=") }.join("&") + "SECRET" }
      expect(sign).to eq('cc2f3b4894dd34fe101df3d06184c386')
    end
  end

  context '#sign!' do
    it "should append a new specified key with signature-value to current hash" do
      signable.sign!(:sign, 'MD5'){|hash| hash.to_a.collect{|i| i.join("=") }.join("&") + "SECRET" }
      expect(signable[:sign]).to eq('cc2f3b4894dd34fe101df3d06184c386')
    end
  end

  context '#to_query' do
    it 'should return a URL formatted string in order' do
      expect(signable.to_query).to eq("bar=Bar&foo=Foo&url=http%3A%2F%2Fexample.com")
    end
  end

  context '#merge_if!' do
  end
end