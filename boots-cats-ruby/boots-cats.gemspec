# frozen_string_literal: true

require_relative 'lib/boots_cats/version'

Gem::Specification.new do |spec|
  spec.name = 'boots-cats'
  spec.version = BootsCats::VERSION
  spec.authors = ['Konstantin Gredeskoul']
  spec.email = ['kigster@gmail.com']

  spec.summary = 'Multi-player Boots and Cats for Academia.EDU interview'
  spec.description = 'Multi-player Boots and Cats.'
  spec.homepage = 'https://github.com/kigster/boots-cats'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kigster/boots-cats'
  spec.metadata['changelog_uri'] = 'https://github.com/kigster/boots-cats'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end

  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'eventmachine'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
