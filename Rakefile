# frozen_string_literal: true

require "decidim/dev/common_rake"

def install_module(path)
  original_folder = Dir.pwd
  Dir.chdir(path)
  system("bundle exec rake decidim_plans:install:migrations")
  system("bundle exec rake db:migrate")
  Dir.chdir(original_folder)
end

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app" do
  ENV["RAILS_ENV"] = "test"
  install_module("spec/decidim_dummy_app")
end

desc "Generates a development app"
task development_app: "decidim:generate_external_development_app" do
  install_module("development_app")
end

# Run all tests, include all
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

# Run both by default
task default: [:spec]
