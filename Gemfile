# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/plans/version"

DECIDIM_VERSION = Decidim::Plans.decidim_version

gem "decidim", DECIDIM_VERSION
gem "decidim-proposals", DECIDIM_VERSION

gem "decidim-favorites", github: "mainio/decidim-module-favorites", branch: "main"
gem "decidim-feedback", github: "mainio/decidim-module-feedback", branch: "main"
gem "decidim-tags", github: "mainio/decidim-module-tags", branch: "main"

gem "decidim-plans", path: "."

gem "bootsnap", "~> 1.17"

gem "puma", ">= 6.4.2"

gem "faker", "~> 3.2.2"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  # Fix issue with simplecov-cobertura
  # See: https://github.com/jessebs/simplecov-cobertura/pull/44
  gem "rexml", "3.4.1"

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "decidim-admin", DECIDIM_VERSION
  gem "decidim-assemblies", DECIDIM_VERSION
  gem "decidim-budgets", DECIDIM_VERSION
  gem "decidim-participatory_processes", DECIDIM_VERSION
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.8"
  gem "rubocop-faker"
  gem "web-console", "~> 4.2"
end
