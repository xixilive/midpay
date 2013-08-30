# Midpay

A Rack Middleware for E-Commerce Payment Base-Strategy

## Installation

Add this line to your application's Gemfile:

    gem 'midpay'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install midpay

## Usage

For example, we have a strategy named Foo as following:
```ruby
class Foo
  include ::Midpay::Strategy

  def request_phase response
    response.write("You are being redirected to a payment gateway......")
    response.redirect a_url_for_payment_gateway_with_some_parameters
  end

  def callback_phase payment_info
    payment_info.extra = EXTRA_INFO #... whatever
    payment_info.raw_data = RAW_DATA #... whatever
    payment_info.success = true
  end
end

#register your strategy
::Midpay[:foo] = ::Foo
```

In your rack app:

```ruby
use ::Midpay[:foo], YOUR_APPID, YOUR_KEY, :request_params_proc => {|params| 
  obj = BarModel.find(params[:bar_id])
  {
    :key1 => obj.value1,
    :key2 => obj.value2
    # all of the params to be sent to your payment gateway on request phase
  } 
}
```

Send a request to Payment Gateway:

```ruby
get '/midpay/foo?bar_id=123'
```

Handle gateway callback request in your controller:
```ruby
  def callback
    current_strategy = request.env['midpay.strategy']
    callback_data = request.env['midpay.callback']
    # handle the callback logic
  end
```

For more details at WIKI

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
