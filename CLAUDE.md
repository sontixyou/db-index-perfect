# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails 8.0.3 REST API backend with MySQL 8.0 and Elasticsearch 8.11 running in Docker containers. Uses dotenv-rails for environment configuration and Searchkick for Elasticsearch integration.

## Database Setup

MySQL 8.0 and Elasticsearch run in Docker containers (not the Rails app itself). Configuration:

### MySQL
- Host: localhost (default)
- Port: 3306
- Username: dbuser
- Password: dbpassword
- Development DB: db_index_perfect_development

Database credentials are configured via environment variables in `config/database.yml`:
- `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`

### Elasticsearch
- Host: localhost
- Port: 9200 (HTTP), 9300 (transport)
- Security: disabled (xpack.security.enabled=false)
- Environment variable: `ELASTICSEARCH_URL` (defaults to http://localhost:9200)

## Common Commands

### Docker
```bash
# Start all services (MySQL + Elasticsearch)
docker-compose up -d

# Start only MySQL
docker-compose up -d mysql

# Start only Elasticsearch
docker-compose up -d elasticsearch

# Stop all containers
docker-compose down

# View logs
docker-compose logs mysql
docker-compose logs elasticsearch

# Connect to MySQL CLI
docker exec -it db-index-perfect-mysql mysql -u dbuser -p
```

### Rails Development
```bash
# Install dependencies
bundle install

# Database operations
rails db:create          # Create database
rails db:migrate         # Run migrations
rails db:rollback        # Rollback last migration
rails db:schema:load     # Load schema from db/schema.rb

# Start server
rails server             # Starts on http://localhost:3000

# Generate migration
rails generate migration MigrationName

# Code quality
rubocop                  # Run linter (Rails Omakase style)
brakeman                 # Run security scanner

# Testing
rails test               # Run all tests
rails test test/models/user_test.rb  # Run specific test file
```

### Data Generation Tasks
```bash
# Create 10 million users with bulk insert
rails db:create_bulk_users

# Create user_profiles for existing users (4 randomized careers per user)
rails user_profile:create_profiles
```

### Searchkick/Elasticsearch Tasks
```bash
# Reindex all models (User and UserProfile)
rails searchkick:reindex_all

# Reindex limited number of records for testing (default: 1000)
rails searchkick:reindex_sample LIMIT=5000
```

## Architecture

### API Structure
- All API endpoints under `/api/v1/` namespace
- Controllers in `app/controllers/api/v1/`
- Routes defined in `config/routes.rb` under `namespace :api, :v1`
- Root path (`/`) maps to health_check endpoint

### Search Architecture
- Uses Searchkick gem for Elasticsearch integration
- Models: `User` and `UserProfile` include `searchkick` with `callbacks: false`
- Manual reindexing required via rake tasks (callbacks disabled for performance with large datasets)
- Word-start search enabled for: `User` (first_name, last_name, email), `UserProfile` (career)
- Search endpoints in `SearchController` for users and user_profiles

### Multi-Database Production Setup
Production uses multiple databases via Rails multi-database feature:
- `primary` - Main application data
- `cache` - Solid Cache (Rails 8 database-backed cache)
- `queue` - Solid Queue (Rails 8 database-backed jobs)
- `cable` - Solid Cable (Rails 8 database-backed Action Cable)

Each has separate migration paths (`db/cache_migrate`, `db/queue_migrate`, `db/cable_migrate`).

### Current Endpoints
- `GET /` or `GET /api/v1/health_check` - Health check with DB status
- `GET /api/v1/users` - List users
- `POST /api/v1/users` - Create user
- Other standard REST actions for users resource
- `GET /api/v1/search/users` - Search users via Elasticsearch
- `GET /api/v1/search/user_profiles` - Search user profiles via Elasticsearch

### Database Schema
- `users` table:
  - email (string)
  - first_name (string, indexed with B-tree)
  - last_name (string)
  - created_at, updated_at
  - has_one :user_profile

- `user_profiles` table:
  - user_id (bigint, foreign key, indexed)
  - career (text, fulltext indexed)
  - created_at, updated_at
  - belongs_to :user

### Key Dependencies
- `searchkick` - Elasticsearch integration
- `elasticsearch` ~> 8.0 - Elasticsearch client
- `faker` - Test data generation for bulk user creation
- `solid_cache`, `solid_queue`, `solid_cable` - Rails 8 database-backed adapters
