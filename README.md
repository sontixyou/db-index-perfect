# DB Index Perfect - Rails API with MySQL

Rails REST API backend connected to MySQL 8.0 running in Docker container.

## Requirements

- Ruby 3.4.6
- Rails 8.0.3
- Docker and Docker Compose
- MySQL 8.0 (via Docker)

## Setup

### 1. Start MySQL Database Container

```bash
docker-compose up -d mysql
```

This will start MySQL 8.0 container with:
- Database: `db_index_perfect_development`
- Username: `dbuser` 
- Password: `dbpassword`
- Port: `3306`

### 2. Install Dependencies

```bash
bundle install
```

### 3. Setup Database

```bash
rails db:create
rails db:migrate
```

### 4. Start Rails Server

```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Health Check
- `GET /` or `GET /api/v1/health_check` - Returns API status and database connection status

Example response:
```json
{
  "status": "OK",
  "message": "API is running",
  "database": "Connected",
  "timestamp": "2024-10-04T05:20:00.000Z"
}
```

## Environment Variables

Copy `.env.development` to `.env` and modify as needed:

```bash
cp .env.development .env
```

Available environment variables:
- `DB_HOST` - Database host (default: localhost)
- `DB_PORT` - Database port (default: 3306)
- `DB_USERNAME` - Database username (default: dbuser)
- `DB_PASSWORD` - Database password (default: dbpassword)

## Docker Commands

```bash
# Start MySQL container
docker-compose up -d mysql

# Stop MySQL container
docker-compose down

# View container logs
docker-compose logs mysql

# Connect to MySQL directly
docker exec -it db-index-perfect-mysql mysql -u dbuser -p
```

## Development

### Adding New API Endpoints

1. Create controller in `app/controllers/api/v1/`
2. Add routes in `config/routes.rb` under the `api/v1` namespace
3. Test the endpoint

### Database Migrations

```bash
# Generate migration
rails generate migration CreateTableName

# Run migrations
rails db:migrate

# Rollback
rails db:rollback
```
