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

  # rubocop & rubocop-rspec are set to the following versions because of a change where FactoryBot/CreateList
  # must be a boolean instead of contextual. These version locks can be removed when this problem is handled
  # through decidim-dev.
  gem "rubocop", "~>1.28"
  gem "rubocop-rspec", "2.20"

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.8"
  gem "rubocop-faker"
  gem "spring", "~> 4.1.3"
  gem "spring-watcher-listen", "~> 2.1"
  gem "web-console", "~> 4.2"
end
