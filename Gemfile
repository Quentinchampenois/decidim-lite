# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim-system", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-admin", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-api", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-core", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-participatory_processes", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-verifications", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-comments", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-accountability", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-assemblies", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-blogs", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-budgets", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-debates", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-forms", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-surveys", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-meetings", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-pages", github: 'decidim/decidim', tag: 'v0.29.0'
gem "decidim-proposals", github: 'decidim/decidim', tag: 'v0.29.0'

gem "bootsnap", "~> 1.4"

gem "puma", ">= 6.3.1"

gem "spring"
gem "dotenv-rails", "~> 2.7"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", github: 'decidim/decidim', tag: 'v0.29.0'

  gem "brakeman", "~> 6.1"
  gem "parallel_tests", "~> 4.2"
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 4.2"
end

group :production do
  gem "activejob-uniqueness", require: "active_job/uniqueness/sidekiq_patch"
  gem "sidekiq", "~> 6.0"
  gem "sidekiq-scheduler", "~> 5.0"
end

group :development do
  # Profiling gems
  gem "bullet"
  gem "flamegraph"
  gem "memory_profiler"
  gem "rack-mini-profiler", require: false
  gem "stackprof"
end
