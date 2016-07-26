require 'webmock/rspec'

require 'rspec'
require 'portal_translator'

describe PortalTranslator do
  # include PortalTranslator
  def redis
    @redis_nasoska = Redis.new
  end

  context 'translate' do
    context 'heureka.cz' do
      context 'direct translation' do
        before(:context) do
          @heureka_name  = 'muj-testovaci-obchod-domena'
          @shop_name     = 'obchod.domena'
          PortalTranslator.save_original_to_translated(
            redis: redis,
            translated_shop: @shop_name,
            original_shop: @heureka_name,
            portal: 'heureka.cz')
          @test_array = [
            {
              'shop'   => 'muj-testovaci-obchod-domena',
              'portal' => 'heureka.cz',
            }
          ]
          PortalTranslator.translate_exit_link(redis, @test_array)
        end

        it 'should be translated' do
          expect(
            @test_array[0]['shop']).to eq(@shop_name)
        end
      end
      context 'translation via url' do
        before :context do
          @stubbed_url = 'http://cokoliv.cz/'
          @test_array = [
            {
              'shop'   => 'totalni hovadina',
              'portal' => 'heureka.cz',
              'url'    => 'http://heureka.cz' }]


          stub_request(:get, 'http://heureka.cz/').
              with(:headers =>
                       {
                           'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'
                       }).
              to_return(
                  :status => 200,
                  :body => '',
                  :headers => { 'Location' => 'http://cokoliv.cz' }
              )
          PortalTranslator.translate_exit_link(redis, @test_array)
        end

        it 'url should be cokoliv.cz' do
          expect(@test_array[0]['url']).to eq(@stubbed_url)
        end

        it 'shop should be cokoliv.cz' do
          expect(@test_array[0]['shop']).to eq('cokoliv.cz')
        end

        it 'totalni hovadina should be translated as cokoliv.cz' do
          expect(
            PortalTranslator.name_original_to_translated(
              redis, 'totalni hovadina', 'heureka.cz')).to eq('cokoliv.cz')
        end
      end
    end

    context 'zbozi.cz' do
      context 'direct translation' do
        before(:context) do
          @heureka_name  = 'muj-testovaci-obchod-domena'
          @shop_name     = 'obchod.domena'
          PortalTranslator.save_original_to_translated(
            redis: redis,
            translated_shop: @shop_name,
            original_shop: @heureka_name,
            portal: 'zbozi.cz')
          # create test shop in RedisDb
          @test_array = [
            {
              'shop'   => 'muj-testovaci-obchod-domena',
              'portal' => 'zbozi.cz',
            }
          ]
          PortalTranslator.translate_exit_link(redis, @test_array)
        end

        it 'should be translated' do
          expect(
            @test_array[0]['shop']).to eq(@shop_name)
        end
      end

      context 'translation via url' do
        before :context do
          @stubbed_url = 'http://uplnejinecokoliv.cz/'
          stub_request(:get, 'http://zbozi.cz')
            .to_return(
              status: 200,
              body: '',
              headers: { 'Location' => 'http://uplnejinecokoliv.cz' })

          @test_array = [
            {
              'shop'   => 'totalni hovadina',
              'portal' => 'zbozi.cz',
              'url'    => 'http://zbozi.cz' }]
          PortalTranslator.translate_exit_link(redis, @test_array)
        end

        it 'url should be uplnejinecokoliv.cz' do
          expect(@test_array[0]['url']).to eq(@stubbed_url)
        end

        it 'shop should be uplnejinecokoliv.cz' do
          expect(@test_array[0]['shop']).to eq('uplnejinecokoliv.cz')
        end

        it 'totalni hovadina should be translated as uplnejinecokoliv.cz' do
          expect(
            PortalTranslator.name_original_to_translated(
              redis, 'totalni hovadina', 'zbozi.cz')).to eq('uplnejinecokoliv.cz')
        end
      end
    end

    context 'pricemania.sk' do
      context 'translation via url' do
        before :context do
          stub_request(:get, 'http://pricemania.sk')
              .to_return(
                  status: 200,
                  body: '',
                  headers: { 'Location' => 'http://zlyobchod.pl' })

          @test_array = [
              {
                  'shop'   => 'Zle Krowky',
                  'portal' => 'pricemania-sk',
                  'url'    => 'http://pricemania.sk' }]
          PortalTranslator.translate_exit_link(redis, @test_array)
        end

        it 'url should be zlyobchod.pl' do
          expect(@test_array[0]['url']).to eq('http://zlyobchod.pl/')
        end

        it 'shop should be zlyobchod.pl' do
          expect(@test_array[0]['shop']).to eq('zlyobchod.pl')
        end
      end

      context 'translation via url with XPATH' do
        before :context do
          @stubbed_url = 'http://dobryobchod.pl/'
          response = '<!DOCTYPE HTML><html><head>meta http-equiv="content-type"' \
            ' content="text/html" /></head><body>' \
            '<a href="http://dobryobchod.pl/">sem</a></body></html>'

          stub_request(:get, 'http://pricemania.sk')
              .to_return(
                  status: 200,
                  body: response,
                  headers: { 'Location' => 'http://pricemania.sk' })

          @test_array = [
              {
                  'shop'   => 'Dobre Krowky',
                  'portal' => 'pricemania-sk',
                  'url'    => 'http://pricemania.sk' }]
          PortalTranslator.translate_exit_link(redis, @test_array)
        end

        it 'url should be dobryobchod.pl' do
          expect(@test_array[0]['url']).to eq(@stubbed_url)
        end

        it 'shop should be dobryobchod.pl' do
          expect(@test_array[0]['shop']).to eq('dobryobchod.pl')
        end
      end
    end

    context 'settings' do
      context 'keep_exit_url' do
        before :context do
          @stubbed_url = 'http://cokoliv.cz/'
          @test_array = [
              {
                  'shop'   => 'totalni hovadina',
                  'portal' => 'heureka.cz',
                  'url'    => 'http://heureka.cz' }]

          @test_array_no_exit = [
              {
                  'shop'   => 'totalni hovadina',
                  'portal' => 'heureka.cz',
                  'url'    => 'http://heureka.cz' }]


          stub_request(:get, 'http://heureka.cz/').
              with(:headers =>
                       {
                           'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'
                       }).
              to_return(
                  :status => 200,
                  :body => '',
                  :headers => { 'Location' => 'http://cokoliv.cz' }
              )
          settings = { keep_exit_url: true }
          PortalTranslator.translate_exit_link(redis, @test_array, settings)
          PortalTranslator.translate_exit_link(redis, @test_array_no_exit)
        end

        it 'url should be cokoliv.cz' do
          expect(@test_array[0]['url']).to eq(@stubbed_url)
        end

        it 'shop should be cokoliv.cz' do
          expect(@test_array[0]['shop']).to eq('cokoliv.cz')
        end

        it 'shop should have exit_url' do
          expect(@test_array[0]['url_exit']).to eq('http://heureka.cz')
        end

        it 'totalni hovadina should be translated as cokoliv.cz' do
          expect(
              PortalTranslator.name_original_to_translated(
                  redis, 'totalni hovadina', 'heureka.cz')).to eq('cokoliv.cz')
        end

        it 'url should be cokoliv.cz' do
          expect(@test_array_no_exit[0]['url']).to eq(@stubbed_url)
        end

        it 'shop should be cokoliv.cz' do
          expect(@test_array_no_exit[0]['shop']).to eq('cokoliv.cz')
        end

        it 'shop should not have exit_url' do
          expect(@test_array_no_exit[0]['exit_url']).to be_nil
        end
      end

      context 'portal' do
        before :context do
          @stubbed_url = 'http://cokoliv.cz/'
          @test_array = [
              {
                  'shop'   => 'totalni hovadina',
                  'url'    => 'http://heureka.cz' }]

          stub_request(:get, 'http://heureka.cz/').
              with(:headers =>
                       {
                           'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'
                       }).
              to_return(
                  :status => 200,
                  :body => '',
                  :headers => { 'Location' => 'http://cokoliv.cz' }
              )
          settings = { portal: 'heureka.cz' }
          PortalTranslator.translate_exit_link(redis, @test_array, settings)

        end

        it 'url should be cokoliv.cz' do
          expect(@test_array[0]['url']).to eq(@stubbed_url)
        end

        it 'shop should be cokoliv.cz' do
          expect(@test_array[0]['shop']).to eq('cokoliv.cz')
        end

        it 'totalni hovadina should be translated as cokoliv.cz' do
          expect(
              PortalTranslator.name_original_to_translated(
                  redis, 'totalni hovadina', 'heureka.cz')).to eq('cokoliv.cz')
        end

        it 'shop should not have exit_url' do
          expect(@test_array[0]['exit_url']).to be_nil
        end
      end
    end
  end
end


