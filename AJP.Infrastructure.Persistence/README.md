# Database Infrastructure & Migrations

This document explains how the database infrastructure is set up and managed in the AJP.KubeExample application.

## Overview

The application uses:
- **PostgreSQL** as the relational database
- **Dapper** as the micro-ORM for data access
- **Flyway** for database migrations
- **DevSpace** for Kubernetes deployment

## Architecture

### Infrastructure Components

1. **PostgreSQL Database**
   - Deployed as a Kubernetes pod
   - Data stored in a persistent volume (in production) or emptyDir (in development)
   - Exposed through a Kubernetes service

2. **Flyway Migration Tool**
   - Deployed as a Kubernetes pod
   - Migration SQL files mounted from the host or ConfigMap
   - Used to apply schema changes in a versioned, controlled manner

3. **Application Repositories**
   - Implement repository interfaces defined in the Application layer
   - Use Dapper for efficient SQL access
   - Connect to PostgreSQL via standard connection string

## Database Access Pattern

The application follows a Clean Architecture approach with the Repository Pattern:

1. **Domain Layer** defines entities (e.g., `Product`, `Order`)
2. **Application Layer** defines repository interfaces (e.g., `IProductRepository`)
3. **Persistence Layer** implements repository interfaces using Dapper

### Example Repository Implementation

```csharp
public class ProductRepository : IProductRepository
{
    private readonly IDbConnection _dbConnection;
    private readonly ILogger<ProductRepository> _logger;

    public ProductRepository(IDbConnection dbConnection, ILogger<ProductRepository> logger)
    {
        _dbConnection = dbConnection;
        _logger = logger;
    }

    public async Task<IEnumerable<Product>> GetAllAsync()
    {
        const string sql = "SELECT * FROM Products ORDER BY Id";
        return await _dbConnection.QueryAsync<Product>(sql);
    }

    // Additional methods for CRUD operations
}
```

## Migrations Management

### Migration Files

Migration files are SQL scripts located in the `/migrations` directory at the project root. 
They follow Flyway's naming convention:

```
V{yyyyMMddHHmmss}__{description}.sql
```

Example: `V20250921002712__add_orders_table.sql`

### Migration Types

The project includes several types of migrations:

1. **Schema Migrations**: Create or alter database tables
2. **Reference Data**: Insert static lookup data (e.g., categories, roles)
3. **Sample Data**: Insert test data for development

### Current Database Schema

The database includes the following tables:

- `products`: Product catalog information
- `categories`: Product categories
- `product_categories`: Many-to-many relationship between products and categories
- `users`: User accounts
- `user_roles`: Available user roles (Admin, User, Manager)
- `user_to_roles`: Many-to-many relationship between users and roles
- `orders`: Customer orders with shipping information
- `order_items`: Line items for each order
- `product_reviews`: Customer reviews for products
- `flyway_schema_history`: Tracks applied migrations

## Running Migrations

### Development Environment

In the development environment, migrations are managed using DevSpace commands:

```bash
# Run pending migrations
devspace run migrate-db

# Create a new migration
devspace run create-migration <migration_name>

# Check migration status
devspace run db-info
```

These commands can also be executed from VS Code's launch configurations.

### How Migrations Work

1. The migration files are stored in the `/migrations` directory
2. When running `migrate-db`:
   - Files are copied to the Flyway pod using `kubectl cp`
   - Flyway executes the migrations in version order
   - Flyway tracks applied migrations in the `flyway_schema_history` table

### Migration Best Practices

1. **Always be additive**: Don't modify existing migrations after they've been applied
2. **Idempotent scripts**: Use `IF NOT EXISTS` clauses for schema changes
3. **Small migrations**: Keep migrations focused on specific changes
4. **Transaction management**: Use transactions for complex changes
5. **Backwards compatibility**: Ensure migrations don't break existing code

## Production Deployment Options

For production environments, we support several options:

### 1. Persistent Volume for Migrations

Migrations are stored in a Kubernetes PersistentVolumeClaim:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: flyway-migrations-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### 2. Custom Docker Image

For a more robust solution, build a custom Docker image containing the migrations:

```dockerfile
FROM flyway/flyway:9.21

# Copy migration scripts
COPY migrations/ /flyway/sql/

# Set default command
ENTRYPOINT ["flyway"]
CMD ["-url=jdbc:postgresql://postgres:5432/ajp_db", "-user=postgres", "-password=postgres", "migrate"]
```

### 3. Kubernetes Job

Run migrations as a Kubernetes Job during deployment:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: flyway-migration-job
spec:
  template:
    spec:
      containers:
      - name: flyway
        image: your-registry/flyway-migrations:v1
        args:
          - -url=jdbc:postgresql://postgres:5432/ajp_db
          - -user=postgres
          - -password=postgres
          - migrate
      restartPolicy: OnFailure
```

## Connection Configuration

### Development Environment

In development, the connection string is set in the `appsettings.Development.json` file:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=ajp_db;Username=postgres;Password=postgres"
  }
}
```

When running in Kubernetes, the connection string is overridden by environment variables:

```yaml
env:
  - name: ConnectionStrings__DefaultConnection
    value: "Host=postgres;Port=5432;Database=ajp_db;Username=postgres;Password=${POSTGRES_PASSWORD}"
```

### DI Registration

Database connections are registered in the DI container in `AJP.Infrastructure.Persistence/DependencyInjection.cs`:

```csharp
public static IServiceCollection AddPersistence(this IServiceCollection services, IConfiguration configuration)
{
    // Register database connection
    services.AddScoped<IDbConnection>(sp =>
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection");
        return new NpgsqlConnection(connectionString);
    });

    // Register repositories
    services.AddScoped<IProductRepository, ProductRepository>();
    // Add other repositories

    return services;
}
```

## Debugging Database Issues

To debug database issues:

1. Check migration status: `devspace run db-info`
2. Connect to database directly: `./db-connect.sh`
3. View Flyway pod logs: `kubectl logs -l app.kubernetes.io/component=flyway`
4. View PostgreSQL pod logs: `kubectl logs -l app.kubernetes.io/component=postgres`

## Extending the Database

To add a new entity to the database:

1. Add the entity class in the Domain layer
2. Define the repository interface in the Application layer
3. Create a migration file with `devspace run create-migration add_entity_name`
4. Implement the repository in the Persistence layer
5. Register the repository in DependencyInjection.cs
6. Run the migration with `devspace run migrate-db`

## Conclusion

This persistence infrastructure provides a robust, maintainable approach to database management with:

- Clean separation of concerns
- Version-controlled migrations
- Easy development workflow
- Production-ready deployment options
- Type-safe data access with Dapper
