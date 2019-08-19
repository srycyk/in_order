$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "in_order/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "in_order"
  spec.version     = InOrder::VERSION
  spec.authors     = ["Stephen Rycyk"]
  spec.email       = ["stephen.rycyk@googlemail.com"]
  spec.homepage    = "http://github.com/srycyk/in_order"
  spec.summary     = "A Linked List in SQL"
  spec.description = "Links ActiveRecord models together in one-to-many relationships in a preset sequence."
  spec.license     = "MIT"

=begin
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end
=end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails" #, "~> 5.2.3"

  spec.add_development_dependency "sqlite3"
end

