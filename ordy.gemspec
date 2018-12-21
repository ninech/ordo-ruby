lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)


Gem::Specification.new do |spec|
  spec.name        = 'ordy'
  spec.version     = '0.0.0'
  spec.date        = '2018-11-23'
  spec.summary     = 'Simple sorting gem'
  spec.description = 'Ordy simple sorting gem for RubyObject\'s and ORM\'s '
  spec.authors     = ['RadicM']
  spec.email       = 'milos.radic@consulteer.com'
  spec.files       = ['lib/ordy.rb']
  spec.homepage    = 'https://github.com/ninech/ordy'
  spec.license     = 'MIT'

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'appraisal'

  spec.add_runtime_dependency 'activerecord', '>= 4.2.0'
  spec.add_runtime_dependency 'actionview', '>= 4.2.0'
end