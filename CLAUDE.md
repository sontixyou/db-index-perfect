# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails 8.0.3 REST API backend with MySQL 8.0 running in Docker. Uses dotenv-rails for environment configuration.

## Database Setup

MySQL 8.0 runs in Docker container (not the Rails app itself). Configuration:
- Host: localhost (default)
- Port: 3306
- Username: dbuser
- Password: dbpassword
- Development DB: db_index_perfect_development

Database credentials are configured via environment variables in `config/database.yml`:
- `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`

## Common Commands

### Docker (MySQL only)
```bash
# Start MySQL container
docker-compose up -d mysql

# Stop MySQL container
docker-compose down

# View MySQL logs
docker-compose logs mysql

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

## Architecture

### API Structure
- All API endpoints under `/api/v1/` namespace
- Controllers in `app/controllers/api/v1/`
- Routes defined in `config/routes.rb` under `namespace :api, :v1`
- Root path (`/`) maps to health_check endpoint

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

### Database Schema
- `users` table: email (string), created_at, updated_at
  - Note: name column was recently removed
