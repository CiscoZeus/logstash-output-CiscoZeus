Gem::Specification.new do |s|
  s.name          = 'logstash-output-CiscoZeus'
  s.version       = '0.2.1'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Logstash plugin to talk with the CiscoZeus HTTP API'
  s.homepage      = 'http://ciscozeus.io'
  s.authors       = ['Yoel Cabo']
  s.email         = 'ycabolop@cisco.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*', 'spec/**/*', 'vendor/**/*','*.gemspec','*.md','Gemfile','LICENSE']
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0"
  s.add_runtime_dependency "logstash-codec-plain"
  s.add_runtime_dependency "zeusclient", "~> 0"
end
