require 'redis'
require 'typhoeus'
require 'uri'
require 'nokogiri'
require 'helpers/portal_translator_helpers'

module PortalTranslator
  class << self
    # translate heureka shop to real host name
    # mall-cz => mall.cz
    def name_original_to_translated(redis, original_shop, portal)
      real_shop = redis.hget(
        PortalTranslatorHelpers::KEYS[portal][:shop_converter],
        original_shop
      )
      save_translated_to_original(
        redis: redis,
        translated_shop: real_shop,
        original_shop: original_shop,
        portal: portal
      ) if real_shop && !real_shop.empty?
      real_shop
    end

    # translate heureka shop to real host name
    # mall.cz => mall-cz
    def name_translated_to_original(redis, name, portal)
      redis.hget(
        PortalTranslatorHelpers::KEYS[portal][:shop_converter_opposite],
        name
      )
    end

    def save_translated_to_original(redis:, translated_shop:,
                                    original_shop:, portal:)
      redis.hset(
        PortalTranslatorHelpers::KEYS[portal][:shop_converter_opposite],
        translated_shop,
        original_shop
      )
    end

    def save_original_to_translated(redis:, translated_shop:,
                                    original_shop:, portal:)
      redis.hset(
        PortalTranslatorHelpers::KEYS[portal][:shop_converter],
        original_shop,
        translated_shop
      ) unless original_shop =~ /heureka|zbozi\.cz/i
    end

    # request_parameters
    def translate(redis, shops, settings = {})
      max_concurrency = settings[:max_concurrency] ||=
                          PortalTranslatorHelpers::MAX_CONCURRENCY
      hydra = Typhoeus::Hydra.new(max_concurrency: max_concurrency)
      shops.each_with_index do |item, counter|

        next unless item['url'] # should not happen
        PortalTranslatorHelpers.complete_item(item, settings)
        redis_data = PortalTranslatorHelpers.fill_redis_data(item, redis)
        # next if PortalTranslatorHelpers.shop_uri_ok?(
        next if !settings[:follow_url] || PortalTranslatorHelpers.shop_uri_ok?(
          shops[counter], redis_data[:target]
        )
        hydra.queue(request(item, redis_data, settings))
      end
      hydra.run
      save_shops_to_redis(redis, shops)
    end

  private

    def request(item, redis_data, request_parameters)
      request = PortalTranslatorHelpers.create_request(item, request_parameters)
      request.on_complete do |complete|
        url = PortalTranslatorHelpers.find_url(complete, item)
        regex = /pricemania/
        if item['portal'] =~ regex && url =~ regex
          url = PortalTranslatorHelpers.hack_pricemania(complete)
        end
        PortalTranslatorHelpers.save_translated_link_to_redis(
          redis_data[:redis],
          redis_data[:exit_key],
          redis_data[:key],
          url
        )
        item['url'] = url
      end
      request
    end

    def save_shops_to_redis(redis, shops)
      shops.each do |shop|
        shop_name = PortalTranslatorHelpers.get_host_without_www(shop['url'])
        shop['original_shop'] = shop['shop'] if shop['shop']
        shop['shop'] =
          if PortalTranslatorHelpers.shop_name_with_portal?(shop, shop_name)
            name_original_to_translated(
              redis,
              shop['shop'],
              shop['portal']
            ) ||
              shop['original_shop']
          else
            save_shop_name_to_redis(redis, shop, shop_name)
          end
      end
      shops
    end

    def save_shop_name_to_redis(redis, shop, shop_name)
      save_original_to_translated(
        redis: redis,
        original_shop: shop['shop'],
        translated_shop: shop_name,
        portal: shop['portal']
      )
      save_translated_to_original(
        redis: redis,
        translated_shop: shop_name,
        original_shop: shop['shop'],
        portal: shop['portal']
      )
      shop_name
    end
  end
end
