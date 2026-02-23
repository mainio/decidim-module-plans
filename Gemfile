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
gem "decidim-feedback", github: "mainio/decidim-module-feedback", branch: "release/0.28-stable"
gem "decidim-tags", github: "mainio/decidim-module-tags", branch: "release/0.28-stable"

gem "decidim-plans", path: "."

gem "bootsnap", "~> 1.17"

# This is a temporary fix for: https://github.com/rails/rails/issues/54263
# Without this downgrade Activesupport will give error for missing Logger
gem "concurrent-ruby", "1.3.4"

gem "puma", ">= 6.4.2"

gem "faker", "~> 3.2.2"

# This locks nokogiri to a version < 1.17 so it doesn't cause issues
gem "nokogiri", "1.16.8"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  # rubocop & rubocop-rspec are set to the following versions because of a change where FactoryBot/CreateList
  # must be a boolean instead of contextual. These version locks can be removed when this problem is handled
  # through decidim-dev.
  gem "rubocop", "~>1.28"
  gem "rubocop-rspec", "2.20"

  # Fix issue with simplecov-cobertura
  # See: https://github.com/jessebs/simplecov-cobertura/pull/44
  gem "rexml", "3.4.1"

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.8"
  gem "rubocop-faker"
  gem "web-console", "~> 4.2"
end
