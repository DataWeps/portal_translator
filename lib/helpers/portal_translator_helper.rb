module PortalTranslator
  module PortalTranslatorHelper
    KEYS = {
      'heureka.cz' => {
        exit_key: 'Heureka::Exit',
        shop_converter: 'shop_converter::heureka',
        shop_converter_opposite: 'shop_converter::opposite::heureka'
      },
      'heureka.sk' => {
        exit_key: 'Heureka::Exit',
        shop_converter: 'shop_converter::heureka',
        shop_converter_opposite: 'shop_converter::opposite::heureka'
      },
      'zbozi.cz' => {
        exit_key: 'ZboziCz::Exit',
        shop_converter: 'shop_converter::zbozi',
        shop_converter_opposite: 'shop_converter::opposite::zbozi'
      },
      'pricemania.sk' => {
        exit_key: 'PricemaniaSk::Exit',
        shop_converter: 'shop_converter::pricemania-sk'
      }
    }.freeze

    HEUREKA_REGEX = /heureka/

    MAX_CONCURRENCY = 20
    class << self
      def get_rdb_key(item)
        if item['portal'] =~ /heureka/
          item['url'].sub!("?#{uri_parse(item['url']).query}", '')
          return uri_parse(item['url']).path.sub('/exit/', '')
        end
        Digest::MD5.hexdigest("#{item['name']}#{item['shop']}")
      end

      def uri_parse(url)
        URI.parse(url)
      rescue URI::InvalidURIError
        nil
      rescue
        nil
      end

      def create_request(item, request_parameters)
        params =
          if item['portal'] == HEUREKA_REGEX
            { method: :head, followlocation: true }
          else
            { method: :get, followlocation: true }
          end
        proxy = request_parameters[:connect] ||= {}
        Typhoeus::Request.new(item['url'], proxy.merge(params))
      end

      def clean_url(url)
        url.sub!(/[&?#](?:utm_\w+|kampan|ref|campaign)=.*$/, '')
        url = uri_parse(url) || (return nil)
        url.normalize.to_s
      rescue ArgumentError
        nil
      end

      def get_host_without_www(url)
        uri = with_scheme(url) || (return nil)
        return nil unless uri && uri.host
        uri.host.downcase.sub(/\Awww[^\.]*\./, '')
      end

      def with_scheme(url)
        uri = uri_parse(url) || (return nil)
        uri = uri_parse("http://#{url}") if uri.scheme.nil?
        uri
      end

      def save_translated_link_to_redis(redis, key, rdb_key, url)
        redis.hset(key, rdb_key, url) \
          unless url =~ /heureka/
      end

      def complete_item(item, settings)
        item['portal'] ||= settings[:portal]
        item['url_exit'] = item['url'].dup if settings[:keep_exit_url]
      end

      def fill_redis_data(item, redis)
        p item
        rdb_key = get_rdb_key(item)
        exit_key = KEYS[item['portal']][:exit_key]
        target = redis.hget(exit_key, rdb_key)
        {
          redis: redis,
          key: rdb_key,
          exit_key: exit_key,
          target: target
        }
      end

      def find_url(complete, item)
        url = clean_url(
          complete.headers['Location'] || complete.effective_url || item['url']
        )
        url ? url : item['url']
      end

      def shop_uri_ok?(shop, target)
        return false unless target
        parsed_uri = uri_parse(target)
        if parsed_uri
          shop['url'] = target
          return true
        end
        false
      end

      def hack_pricemania(complete)
        xpath_url = Nokogiri::HTML(complete.body)
                            .at_xpath('//a[@class="clickthrough"]/@href')
        return nil unless xpath_url
        if xpath_url.content =~ /clk.tradedoubler.com.*url\((http.*)\)/
          return clean_url(Regexp.last_match(1))
        end
        clean_url(xpath_url.content)
      end

      def shop_name_with_portal?(shop, shop_name)
        !shop_name ||
          (shop_name && shop_name =~ /#{Regexp.escape(shop['portal'])}/i)
      end
    end
  end
end
