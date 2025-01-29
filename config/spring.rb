# frozen_string_literal: true

return if ENV["RAILS_ENV"] == "production"

require "decidim/spring"

Spring.watch(
  ".ruby-version",
  ".rbenv-vars",
  "tmp/restart.txt",
  "tmp/caching-dev.txt"
)
