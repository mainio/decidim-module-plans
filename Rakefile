# frozen_string_literal: true

require "decidim/dev/common_rake"

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app"

desc "Generates a development app."
task development_app: "decidim:generate_external_development_app" do
  # Install the module itself
  original_folder = Dir.pwd
  Dir.chdir("development_app")
  system("bundle exec rake decidim_plans:install:migrations")
  system("bundle exec rake db:migrate")
  Dir.chdir(original_folder)
end

# Run all tests, include all
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

# Run both by default
task default: [:spec]
