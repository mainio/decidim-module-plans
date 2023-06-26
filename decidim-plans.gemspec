# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/plans/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-plans"
  spec.version = Decidim::Plans::VERSION
  spec.authors = ["Antti Hukkanen"]
  spec.email = ["antti.hukkanen@mainiotech.fi"]

  spec.summary = "Provides a plans component for Decidim."
  spec.description = "Plans component allows people to author plans based on the proposals that can be converted into budgeting projects."
  spec.homepage = "https://github.com/mainio/decidim-module-plans"
  spec.license = "AGPL-3.0"

  spec.files = Dir[
    "{app,config,db,lib}/**/*",
    "LICENSE-AGPLv3.txt",
    "Rakefile",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-core", Decidim::Plans::DECIDIM_VERSION
  spec.add_dependency "decidim-favorites", Decidim::Plans::DECIDIM_VERSION
  spec.add_dependency "decidim-feedback", Decidim::Plans::DECIDIM_VERSION
  spec.add_dependency "decidim-proposals", Decidim::Plans::DECIDIM_VERSION
  spec.add_dependency "decidim-tags", Decidim::Plans::DECIDIM_VERSION
  spec.add_dependency "paper_trail-association_tracking", "~> 2.0"

  spec.add_development_dependency "decidim-admin", Decidim::Plans::DECIDIM_VERSION
  spec.add_development_dependency "decidim-assemblies", Decidim::Plans::DECIDIM_VERSION
  spec.add_development_dependency "decidim-budgets", Decidim::Plans::DECIDIM_VERSION
  spec.add_development_dependency "decidim-dev", Decidim::Plans::DECIDIM_VERSION
  spec.add_development_dependency "decidim-participatory_processes", Decidim::Plans::DECIDIM_VERSION
end
