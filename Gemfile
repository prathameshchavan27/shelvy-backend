source "https://rubygems.org"

ruby "3.3.0" # Specify the Ruby version

# Core Rails
gem "rails", "~> 7.2.2", ">= 7.2.2.1"

# Database
gem "pg", "~> 1.5"

# Web Server
gem "puma", ">= 5.0"

# CORS for API requests (needed for React frontend)
gem "rack-cors"

# Authentication & Authorization
gem "devise"             # For authentication
gem "devise-jwt"         # JWT-based auth for API-only apps
gem "jsonapi-serializer"    # JSON serialization for Devise
gem "cancancan"          # Authorization (role-based permissions)

# Background Jobs (Sidekiq)
gem "sidekiq"

# File Uploads (Active Storage with S3, optional)
gem "aws-sdk-s3", require: false

# JSON Serialization
gem "active_model_serializers" # Or use `blueprinter` if you prefer

# Pagination (for APIs with large datasets)
gem "kaminari"

# UUID support for primary keys
# gem "pgcrypto", "~> 0.1.0"

# ENV configuration
gem "dotenv-rails", groups: [ :development, :test ]

# API Documentation
gem "rswag" # Swagger documentation for APIs

# Time zone & data
gem "tzinfo-data", platforms: %i[windows jruby]

# Performance boost
gem "bootsnap", require: false

gem "pundit"

gem "jbuilder"

# -------------------
# Development & Test
# -------------------
group :development, :test do
  # Debugging
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Static security analysis
  gem "brakeman", "~> 7.1.1", require: false

  # Code style checks
  gem "rubocop-rails-omakase", require: false

  # RSpec for testing
  gem "rspec-rails"

  # FactoryBot for test data
  gem "factory_bot_rails"

  # Faker for seed/test data
  gem "faker"

  # Database cleaning between tests
  gem "database_cleaner-active_record"

  # Bullet for detecting N+1 queries
  gem "bullet"

  # Annotate models with schema comments
  gem "annotate"

  gem "shoulda-matchers"
  # Pry for debugging in console
  gem "pry-rails"

  gem "rswag-api"
  gem "rswag-ui"
  gem "rswag-specs"
end

# -------------------
# Test only
# -------------------
group :test do      # Extra matchers for RSpec
  gem "simplecov", require: false # Code coverage reports
end

# -------------------
# Production only
# -------------------
group :production do
  gem "rack-timeout"  # Prevents hanging requests
end
