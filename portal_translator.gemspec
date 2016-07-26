Gem::Specification.new do |s|
  s.name        = 'portal_translator'
  s.version     = '0.0.1'
  s.date        = '2016-07-19'
  s.summary     = 'Portal Translator'
  s.description = 'Gem for converting exit portal links'
  s.authors     = ['Jan Mosat']
  s.email       = 'mosat@weps.cz'
  s.files       = ['lib/portal_translator.rb',
                   'lib/helpers/portal_translator_helpers.rb']
  s.add_runtime_dependency 'redis', '~> 2.2.0'
  s.add_runtime_dependency 'typhoeus', '~> 1.0', '>= 1.0.1'
  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_development_dependency 'bundler', '~> 1.11'
  s.add_development_dependency 'rake', '~> 11.0 '
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rspec-mocks', '~> 3.4'
  s.add_development_dependency 'rubocop', '~> 0.38.0'
  s.homepage      = 'http://dataweps.cz'
  s.license       = 'MIT'
end
