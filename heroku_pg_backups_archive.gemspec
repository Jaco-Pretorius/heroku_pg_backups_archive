# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'heroku_pg_backups_archive/version'

Gem::Specification.new do |spec|
  spec.name          = "heroku_pg_backups_archive"
  spec.version       = HerokuPgBackupsArchive::VERSION
  spec.authors       = ["Hightower"]
  spec.email         = ["engineering@gethightower.com"]

  spec.summary       = %q{Backup your heroku PG database, and archive it to S3.}
  spec.description   = %q{Backup your heroku PG database, and archive it to S3 optionally with SSE-C.}
  spec.homepage      = "https://www.github.com/hightower/heroku_pg_backups_archive"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 2"
  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0"
  spec.add_development_dependency "rspec", "~> 3.5.0"
end
