# PortalTranslator

## Installation

Add this line to your application's Gemfile:

```ruby
require 'portal_translator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install portal_translator

## Usage

```ruby
redis = Redis.new
test_array = [ { portal: 'zbozi.cz', url: http://www.zbozi.cz/clickthru?...'}]
translate_exit_link(redis, test_array)
)
```

### Optional parameters:


```ruby
{
    keep_exit_url: true, # Keeps also original url link
    follow_url: true, # Translates portal exit link to real link to product
    connect: { # Proxy parameters for Typhoeus
        proxy: "proxy.weps.cz:10000", 
        followlocation: true 
        }
    portal: 'zbozi.cz' # Another way to set portal parameter for whole translated array
}
```

###  Portal translations:

```ruby
portal_info = {
    redis: redis,
    translated_shop: shop_name,
    original_shop: zbozi_name,
    portal: 'zbozi.cz'
    }
PortalTranslator.save_original_to_translated(portal_info)
# and
PortalTranslator.save_translated_to_original(portal_info)
```
