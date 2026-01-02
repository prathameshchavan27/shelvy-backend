# Shelvy Backend

A robust, RESTful Inventory Management System API built with Ruby on Rails. Shelvy provides comprehensive warehouse and inventory management capabilities including product tracking, inventory transfers, bundling/unbundling operations, and full audit logging.

![Ruby](https://img.shields.io/badge/Ruby-3.3.0-CC342D?logo=ruby&logoColor=white)
![Rails](https://img.shields.io/badge/Rails-7.2-CC0000?logo=rubyonrails&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-4169E1?logo=postgresql&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

### Authentication & Authorization
- JWT-based authentication using Devise
- Role-based access control (Admin, Manager, Staff)
- Policy-based authorization with Pundit

### Product Management
- Auto-generated SKUs based on brand and product name
- Barcode generation
- Product bundles with component tracking
- Case pack quantity support
- Product metadata storage (JSON)

### Warehouse Management
- Multi-warehouse support
- Inventory locations with capacity limits
- Unique item constraints per location
- Location-based inventory tracking

### Inventory Operations
- **Receiving**: Receive inventory into specific locations
- **Transfers**: Move inventory between locations
- **Bundling**: Combine component products into bundles
- **Unbundling**: Break down bundles into components
- **Status Tracking**: Track inventory status throughout lifecycle

### Audit Logging
- Full audit trail for inventory changes
- Track user actions and modifications
- JSON-based change logs

### API Documentation
- Interactive Swagger/OpenAPI documentation
- Available at `/api-docs`

---

## Getting Started

### Prerequisites

- **Ruby** 3.3.0
- **Rails** 7.2+
- **PostgreSQL** 15+
- **Bundler** 2.0+

### Installation

1. **Clone the repository**
 ```bash
 git clone https://github.com/your-username/shelvy-backend.git
 cd shelvy-backend
 ```

2. **Install dependencies**
 ```bash
 bundle install
 ```

3. **Configure environment variables**
   
 Create a `.env` file in the root directory:
 ```env
 # Database (for production)
 SHELVY_DATABASE_USERNAME=your_db_user
 SHELVY_DATABASE_PASSWORD=your_db_password
 SHELVY_DATABASE_HOST=localhost

 # JWT Secret (generate with: rails secret)
 DEVISE_JWT_SECRET_KEY=your_jwt_secret_key

 # Rails
 RAILS_MASTER_KEY=your_master_key
 ```

4. **Setup the database**
 ```bash
 rails db:create
 rails db:migrate
 rails db:seed  # Optional: load sample data
 ```

5. **Start the server**
 ```bash
 rails server
 ```

 The API will be available at `http://localhost:3000`

---

## Docker Deployment

### Build and run with Docker

```bash
# Build the image
docker build -t shelvy-backend .

# Run the container
docker run -d -p 3000:3000 \
  -e RAILS_MASTER_KEY=<your_master_key> \
  -e SHELVY_DATABASE_HOST=<db_host> \
  -e SHELVY_DATABASE_USERNAME=<db_user> \
  -e SHELVY_DATABASE_PASSWORD=<db_password> \
  shelvy-backend
```

---

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/signup` | Register a new user |
| `POST` | `/api/v1/login` | Login and receive JWT token |
| `DELETE` | `/api/v1/logout` | Logout and invalidate token |

### Products

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/products` | List all products |
| `GET` | `/api/v1/products/:id` | Get product details |
| `POST` | `/api/v1/products` | Create a new product |
| `PUT` | `/api/v1/products/:id` | Update a product |
| `GET` | `/api/v1/products/lookup` | Lookup product by SKU/barcode |

### Warehouses

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/warehouses` | List all warehouses |
| `GET` | `/api/v1/warehouses/:id` | Get warehouse details |

### Inventory Locations

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/inventory_locations/:id` | Get location details |
| `GET` | `/api/v1/inventory_locations/by_warehouse` | Get locations by warehouse |
| `GET` | `/api/v1/inventory_locations/available_capacity` | Check available capacity |
| `GET` | `/api/v1/inventory_locations/:id/history` | Get location movement history |

### Inventory Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/receivings/receive_inventory` | Receive inventory |
| `GET` | `/api/v1/inventory_transfers/locations_to_transfer` | Get transfer options |
| `POST` | `/api/v1/inventory_transfers/transfer_inventory` | Transfer inventory |

### Bundling

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/bundles/:id/bundling_availability` | Check bundling availability |
| `POST` | `/api/v1/bundles/bundle_inventory` | Create bundle from components |
| `GET` | `/api/v1/unbundles/bundles` | List available bundles |
| `POST` | `/api/v1/unbundles/unbundle` | Unbundle into components |

---

## Testing

The project uses RSpec for testing with FactoryBot for test data generation.

```bash
  # Run all tests
  bundle exec rspec
  
  # Run specific test file
  bundle exec rspec spec/models/product_spec.rb
  
  # Run with coverage report
  COVERAGE=true bundle exec rspec
```

### Test Structure
```
spec/
├── factories/          # FactoryBot factories
├── integration/        # API integration tests
├── models/            # Model unit tests
├── policies/          # Pundit policy tests
├── requests/          # Request specs
├── services/          # Service object tests
└── support/           # Test helpers and configuration
```

---

## Database Schema

### Core Models

```
┌─────────────┐     ┌──────────────────┐     ┌────────────────────┐
│   Users     │     │    Warehouses    │     │ Inventory Statuses │
├─────────────┤     ├──────────────────┤     ├────────────────────┤
│ id          │     │ id               │     │ id                 │
│ email       │     │ name             │     │ name               │
│ name        │     │ address          │     └────────────────────┘
│ role        │     └──────────────────┘              │
│ jti         │              │                        │
└─────────────┘              │                        │
       │                     ▼                        │
       │         ┌─────────────────────┐              │
       │         │ Inventory Locations │              │
       │         ├─────────────────────┤              │
       │         │ id                  │              │
       │         │ storage_id          │              │
       │         │ capacity            │              │
       │         │ unique_item_limits  │              │
       │         │ warehouse_id (FK)   │              │
       │         └─────────────────────┘              │
       │                     │                        │
       ▼                     ▼                        ▼
┌─────────────┐     ┌─────────────────────┐
│  Products   │──── │ Inventory Summaries │
├─────────────┤     ├─────────────────────┤
│ id          │     │ id                  │
│ sku         │     │ product_id (FK)     │
│ name        │     │ location_id (FK)    │
│ brand       │     │ status_id (FK)      │
│ barcode     │     │ quantity_on_hand    │
│ price       │     │ reserved_quantity   │
│ is_bundle   │     └─────────────────────┘
│ case_pack   │              │
│ metadata    │              ▼
└─────────────┘     ┌─────────────────────┐
       │            │ Inventory Movements │
       │            ├─────────────────────┤
       ▼            │ id                  │
┌─────────────────┐ │ summary_id (FK)     │
│Bundled Products │ │ transfer_from_id    │
├─────────────────┤ │ transfer_to_id      │
│ bundle_id (FK)  │ │ quantity_moved      │
│ component_id(FK)│ │ description         │
│ quantity        │ └─────────────────────┘
└─────────────────┘
```

---

## Configuration

### Key Configuration Files

| File | Purpose |
|------|---------|
| `config/database.yml` | Database connection settings |
| `config/initializers/devise.rb` | Authentication configuration |
| `config/initializers/cors.rb` | CORS settings for frontend |
| `config/routes.rb` | API route definitions |

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `RAILS_MASTER_KEY` | Rails credentials master key | Production |
| `DEVISE_JWT_SECRET_KEY` | JWT signing secret | Yes |
| `SHELVY_DATABASE_HOST` | PostgreSQL host | Production |
| `SHELVY_DATABASE_USERNAME` | PostgreSQL username | Production |
| `SHELVY_DATABASE_PASSWORD` | PostgreSQL password | Production |

---

## Development Tools

| Tool | Purpose |
|------|---------|
| **RSpec** | Testing framework |
| **FactoryBot** | Test data generation |
| **Faker** | Fake data generation |
| **Rubocop** | Code style enforcement |
| **Brakeman** | Security vulnerability scanning |
| **Bullet** | N+1 query detection |
| **SimpleCov** | Code coverage reports |
| **Annotate** | Model schema annotations |

### Running Code Quality Checks

```bash
# Linting
bundle exec rubocop

# Security scan
bundle exec brakeman

# Generate API documentation
bundle exec rake rswag:specs:swaggerize
```

---

## API Documentation

Interactive API documentation is available via Swagger UI:

```
http://localhost:3000/api-docs
```

The OpenAPI specification file is located at `swagger/v1/swagger.yaml`.

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [Ruby on Rails](https://rubyonrails.org/) - Web framework
- [Devise](https://github.com/heartcombo/devise) - Authentication
- [Pundit](https://github.com/varvet/pundit) - Authorization
- [RSwag](https://github.com/rswag/rswag) - Swagger/OpenAPI integration
