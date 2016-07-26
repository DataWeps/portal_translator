require 'redis'
require 'portal_translator'

redis = Redis.new

heureka_name  = 'muj-testovaci-obchod-domena'
shop_name     = 'obchod.domena'


PortalTranslator.save_original_to_translated(
    redis: redis,
    translated_shop: shop_name,
    original_shop: heureka_name,
    portal: 'heureka.cz')
# create test shop in RedisDb
test_array = [
    {
        'shop'   => 'muj-testovaci-obchod-domena',
        'portal' => 'heureka.cz',
    }
]
PortalTranslator.translate_exit_link(redis, test_array)

puts test_array[0]['shop'] == shop_name
puts test_array

heureka_name  = 'muj-testovaci-obchod-domena'
shop_name     = 'obchod.domena'

PortalTranslator.save_original_to_translated(
    redis: redis,
    translated_shop: shop_name,
    original_shop: heureka_name,
    portal: 'zbozi.cz')

# create test shop in RedisDb
test_array = [
    {
        'shop'   => 'muj-testovaci-obchod-domena',
        'portal' => 'zbozi.cz',
    }
]
PortalTranslator.translate_exit_link(redis, test_array)


puts test_array[0]['shop'] == shop_name

puts test_array

test_array = [
    {'price_vat'=>11990.0,
     'price_novat'=>9909.09,
     'price'=>11990.0,
     'availability'=>true,
     'stock'=>true,
     'portal'=> 'heureka.cz',
     'portal_shop'=>'ONLINESHOP.cz', # check if useless
     'url'=>'http://www.heureka.cz/exit/onlineshop-cz/2274273847/?z=2&t=4dad4dea6b7d0495d7f8344df33b9fb4&p=1',
     'status'=>'ok',
     'updated_at'=>'2016-07-20T12:53:10Z'}]


# test_array = [
#     {
#         'shop'   => 'totalni hovadina',
#         'portal' => 'heureka.cz',
#         'url'    => 'http://heureka.cz' }]
PortalTranslator.translate_exit_link(redis, test_array)

# test_array[0]['url'] == stubbed_url

# puts test_array[0]['url'] == 'http://cokoliv.cz/'

# puts test_array[0]['shop'] == 'cokoliv.cz'

# puts PortalTranslator.name_original_to_translated(redis, 'totalni hovadina', 'heureka.cz') == 'cokoliv.cz'

puts test_array



test_array = [
    {'price_vat'=>11990.0,
     'price_novat'=>9909.09,
     'price'=>11990.0,
     'availability'=>true,
     'stock'=>true,
     'portal'=> 'zbozi.cz',
     'portal_shop'=>'Feedo.cz', # check if useless
     'url'=>'http://www.zbozi.cz/clickthru?c=CmcSPtCNZT53lQXEsAScM76wyfR_JBBbmIjVlJsnXwa32qQFpZcWs7AsMBAaMXdryFXmTvLIB1VSrNNDwlKd3tfUUYjt8q0W_aGuWON3njyO1imSbIS_pPVYco54vjlSiTa0Om9s_qbuXMK1kWym48c2GwI8SesssEX599iaM03vFUiOS_etndgnSm2Qk-XsFYAA1BCfrBXPMx2pkiM9vs_4nOhRuCfL2ubOatIl6P0tSlicoVikmbd_qNb3KeheVB88uBXLx6nPEnuJjvQghuittO2rm4fNUciyu54QUXeCAqx3lGnM4RnPUcDSmnU3AgDEZJz8yeV04iBv91zGuqX79ZRLBjJsP0yFKD6fNGb_qehkdCtadu2QWx_mUJAK7REEuEYs4ieiow6etg==&a=2b519ac5-65bf-4350-b422-4c1a458c49ce',
     'status'=>'ok',
     'updated_at'=>'2016-07-20T12:53:10Z'}]

PortalTranslator.translate_exit_link(redis, test_array, settings = { keep_exit_url: true, connect: { proxy: "proxy.weps.cz:10000", followlocation: true }})

puts test_array


# test_array = [
#     {'price_vat'=>11990.0,
#      'price_novat'=>9909.09,
#      'price'=>11990.0,
#      'availability'=>true,
#      'stock'=>true,
#      'portal'=> 'pricemania-sk',
#      'portal_shop'=>'prva.sk', # check if useless
#      'url'=>'http://www.pricemania.sk/exit/6771955-47-ebdc2641087b2d7a02c4b42ae0d63e07-30-0-0/4621bfc5f6f669989f619ac87111e6e9/',
#      'status'=>'ok',
#      'updated_at'=>'2016-07-20T12:53:10Z'}]
#
# PortalTranslator.translate_exit_link(redis, test_array, settings = {keep_exit_url: true})
#
# puts test_array


test_array =
[
{"shop"=>"megalevnepneu.cz",
 "name"=>"MATADOR MP92 195/ 65 R15 91 T",
 "url"=>"http://www.pricemania.sk/exit/6019735-41821-fe3c9e1c5bb185b2796eb64e57415b9a-30-0-0/0fef71f38b6394659d405d976c4649ca/",
 "price"=>31.54,
 "price_vat"=>37.85,
 "price_novat"=>31.54,
 'portal'=> 'pricemania-sk',
 "availability"=>true}]

PortalTranslator.translate_exit_link(redis, test_array, settings = {keep_exit_url: true})

puts test_array

# test_array = [{'prices_with_fees'=>true,
#   'price'=>801.65,
#   'source_type'=>'product_page',
#   'shop'=>'Pneuboss.cz',
#   'name'=>'Matador Mp92 Sibir Snow 195/65 R 15 91T',
#   'url'=>'http://www.heureka.cz/exit/pneuboss-cz/1665360022/?z=2&t=a7230fbe558698d56e67e1734a6dec52&p=1',
#   'price_vat'=>970.0,
#   'price_novat'=>801.65,
#   'avlbl'=>'skladem',
#   'availability'=>'skladem',
#   'relevance'=>nil},
#  {'prices_with_fees'=>true,
#   'price'=>766.12,
#   'source_type'=>'product_page',
#   'shop'=>'AUTOBATERIE-PNEUMATIKY.CZ',
#   'name'=>'Pneumatiky MATADOR MP92 Sibir Snow 195/65 R15 91T TL Zimní',
#   'url'=>'http://www.heureka.cz/exit/autobaterie-pneumatiky-cz/1337315986/?z=2&t=ded3efe48185338d16c3c0d85eef2e0a&p=2',
#   'price_vat'=>927.0,
#   'price_novat'=>766.12,
#   'avlbl'=>'skladem',
#   'availability'=>'skladem',
#   'relevance'=>nil},
#  {'prices_with_fees'=>true,
#   'price'=>824.79,
#   'source_type'=>'product_page',
#   'shop'=>'Pneumatiky.cz',
#   'name'=>'Matador MP92 Sibir Snow 195/65 R15 91 T Zimní',
#   'url'=>'http://www.heureka.cz/exit/pneumatiky-cz/1682342949/?z=2&t=b6570a274bd6027345a720bfc7aa4914&p=3',
#   'price_vat'=>998.0,
#   'price_novat'=>824.79,
#   'avlbl'=>'skladem',
#   'availability'=>'skladem',
#   'relevance'=>nil},
#  {'prices_with_fees'=>true,
#   'price'=>842.15,
#   'source_type'=>'product_page',
#   'shop'=>'eXtra levné Pneu',
#   'name'=>'Zimní pneu osobní MATADOR MP 92 SIBIR SNOW 195/65 R15 91T',
#   'url'=>'http://www.heureka.cz/exit/pneu-extralevne-pneu-cz/1379825132/?z=2&t=a70c7f25626f2e6d3ef7f81af38f5b4e&p=4',
#   'price_vat'=>1019.0,
#   'price_novat'=>842.15,
#   'avlbl'=>'skladem',
#   'availability'=>'skladem',
#   'relevance'=>nil}]
#
# require 'pp'
#
# PortalTranslator.translate_exit_link(redis, test_array, {} , {keep_exit_url: true, portal: 'heureka.cz'})
#
# pp test_array





# @stubbed_url = 'http://cokoliv.cz/'
# stub_request(:head, 'http://heureka.cz')
#       .to_return(
#           status: 200,
#           body: "stubbed response",
#           headers: { 'Location' => 'http://cokoliv.cz' })
#
#   @test_array = [
#       {
#           'shop'   => 'totalni hovadina',
#           'portal' => 'heureka.cz',
#           'url'    => 'http://heureka.cz' }]
#   TranslateHelper.translate_exit_link(redis, @test_array)
# end
#
# it 'url should be cokoliv.cz' do
#   expect(@test_array[0]['url']).to eq(@stubbed_url)
# end
#
# it 'shop should be cokoliv.cz' do
#   expect(@test_array[0]['shop']).to eq('cokoliv.cz')
# end
#
# it 'totalni hovadina should be translated as cokoliv.cz' do
#   expect(
#       TranslateHelper.name_original_to_translated(
#           redis, 'totalni hovadina', 'heureka.cz')).to eq('cokoliv.cz')
# end


# headers.fetch_headers
# headers.fetch_headers
# puts headers.get_headers(3)
# puts headers.get_random_header


# uri = URI.parse('127.0.0.1')
# req = Net::HTTP::Get.new uri
# response = Net::HTTP.start(uri.hostname, 3000, uri.scheme == 'http') do |http|
#   http.request(req)
# end
# puts response
#
# uri = URI.parse('127.0.0.1')
#   req = Net::HTTP::Get.new(uri)
#   response = Net::HTTP.start(uri.hostname, uri.port) do |http|
#     http.request(req)
#   end
#   puts response

# url = URI.parse('http://127.0.0.1/')
# req = Net::HTTP::Get.new(url.to_s)
# res = Net::HTTP.start(url.host, 3000) {|http|
#   http.request(req)
# }
# puts res.body
# res = Net::HTTP.get_response(url.host, '/?since=2009-11-01', 3000)
# print res.body
