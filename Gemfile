source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.3"

gem "rails", "~> 7.0.4", ">= 7.0.4.2"
gem "pg"
gem "puma", "~> 5.0"
gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "faraday"
gem "rack-cors"
gem "json"
gem "graphql"

group :development, :test do
  gem "pry"
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "graphiql-rails", git: "https://github.com/rmosolgo/graphiql-rails.git", branch: "master"
end