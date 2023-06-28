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
gem "decidim-favorites", github: "mainio/decidim-module-favorites", branch: "release/0.25-stable"
gem "decidim-feedback", github: "mainio/decidim-module-feedback", branch: "release/0.25-stable"
gem "decidim-tags", github: "mainio/decidim-module-tags", branch: "release/0.25-stable"

gem "decidim-plans", path: "."

gem "bootsnap", "~> 1.4.9"
gem "puma", ">= 5.3.1"
gem "uglifier", "~> 4.1"

gem "faker", "~> 2.14"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :test do
  gem "codecov", require: false
end
