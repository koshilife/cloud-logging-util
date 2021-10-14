# frozen_string_literal: true

require_relative "lib/cloud-logging-util/version"

Gem::Specification.new do |spec|
  spec.name          = "cloud-logging-util"
  spec.version       = CloudLoggingUtil::VERSION
  spec.authors       = ["Kenji Koshikawa"]
  spec.email         = ["koshikawa2009@gmail.com"]

  spec.summary       = "Provides a simple logging utility for Cloud Logging."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/koshilife/cloud-logging-util"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/koshilife/cloud-logging-util"
  spec.metadata["changelog_uri"] = "#{spec.metadata["source_code_uri"]}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "codecov"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
end
