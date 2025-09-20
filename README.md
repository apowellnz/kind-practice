# Kubernetes Development Environment with DevSpace, Hot Reload and VS Code Debugging

This guide explains how to set up a streamlined Kubernetes development environment using:
- DevSpace for simplified Kubernetes development workflow
- kind (Kubernetes IN Docker) for local Kubernetes
- React.js application with hot reloading
- .NET Minimal API with hot reloading, DDD architecture, and CQRS pattern
- PostgreSQL database with Dapper for data access
- VS Code debugging integration for all services
- Complete .NET solution structure
- Modern C# coding practices (records, primary constructors, file-scoped namespaces)

## Prerequisites

- Docker Desktop for Linux (with Kubernetes enabled)
- kubectl CLI
- VS Code with appropriate extensions
- Node.js & npm (for React development)
- .NET SDK (for .NET development)
- DevSpace CLI (we'll install this below)

## Getting Started

### 1. Initial Setup

1. Initialize DevSpace in your project:
   ```bash
   devspace init
   ```

2. Run DevSpace to deploy the application:
   ```bash
   devspace dev
   ```

### 2. Database Setup

The application uses PostgreSQL for data storage. When running `devspace dev`, the following happens:

1. PostgreSQL is deployed as a pod in Kubernetes
2. A Flyway migration tool pod is deployed to handle database migrations
3. Initial database migrations are run to create the schema
4. The API can connect to the database

### 3. Managing Database Migrations

The project uses Flyway for database migrations. DevSpace provides commands to make working with migrations easier:

#### Running Migrations
```bash
devspace run migrate-db
```

#### Creating a New Migration
```bash
devspace run create-migration <migration_name>
```
This creates a timestamped SQL file in the `migrations` folder. After adding your SQL, update the ConfigMap:
```bash
kubectl delete configmap flyway-migrations
kubectl create configmap flyway-migrations --from-file=./migrations/
devspace run migrate-db
```

#### Checking Migration Status
```bash
devspace run db-info
```

#### Quick Database Access
Use the `db-connect.sh` script to quickly access the database:
```bash
# Interactive mode
./db-connect.sh

# Run a specific SQL command
./db-connect.sh "SELECT * FROM products"
```

### 4. Database Structure

The database includes the following tables:
- `products`: Stores product information including name, description, price, and stock
- `categories`: Stores category information 
- `product_categories`: Join table linking products to categories
- `users`: User accounts with authentication information
- `user_roles`: Available user roles (Admin, User, Manager)
- `user_to_roles`: Join table linking users to roles
- `orders`: Customer orders with status and shipping information
- `order_items`: Products included in each order
- `flyway_schema_history`: Tracks applied migrations

### 5. Sample Data

Sample data has been pre-loaded into the database, including:
- Electronics, Clothing, and Books categories
- Sample products in each category
- Product-category relationships
- Admin user account

## Troubleshooting

### Image Pull Issues

If you encounter `ImagePullBackOff` errors:
1. Try using a different image tag (e.g., postgres:13 instead of postgres:14)
2. Pull the image locally using `docker pull`
3. Verify network connectivity to Docker Hub

### Database Connection Issues

If the API cannot connect to the database:
1. Verify that the PostgreSQL pod is running with `kubectl get pods`
2. Check the pod logs with `kubectl logs <postgres-pod-name>`
3. Ensure the connection string in the API configuration is correct

## Resources

- [DevSpace Documentation](https://devspace.sh/docs/getting-started/introduction)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Flyway Documentation](https://flywaydb.org/documentation/)

## 2. Creating the .NET Solution Structure with DDD Architecture

Before setting up Kubernetes, let's create a properly structured .NET solution following Domain-Driven Design principles:

### 2.1 Set Up Code Quality and Standardization

First, let's configure code style and package management:

create file: AJP.KubeExample/.editorconfig

```ini
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.cs]
dotnet_sort_system_directives_first = true
dotnet_separate_import_directive_groups = false

dotnet_naming_rule.interface_should_be_begins_with_i.severity = suggestion
dotnet_naming_rule.interface_should_be_begins_with_i.symbols = interface
dotnet_naming_rule.interface_should_be_begins_with_i.style = begins_with_i

dotnet_naming_rule.types_should_be_pascal_case.severity = suggestion
dotnet_naming_rule.types_should_be_pascal_case.symbols = types
dotnet_naming_rule.types_should_be_pascal_case.style = pascal_case

dotnet_naming_rule.non_field_members_should_be_pascal_case.severity = suggestion
dotnet_naming_rule.non_field_members_should_be_pascal_case.symbols = non_field_members
dotnet_naming_rule.non_field_members_should_be_pascal_case.style = pascal_case

dotnet_naming_rule.private_or_internal_field_should_be_camel_case.severity = suggestion
dotnet_naming_rule.private_or_internal_field_should_be_camel_case.symbols = private_or_internal_field
dotnet_naming_rule.private_or_internal_field_should_be_camel_case.style = camel_case_with_underscore

dotnet_naming_symbols.interface.applicable_kinds = interface
dotnet_naming_symbols.interface.applicable_accessibilities = public, internal, private, protected, protected_internal, private_protected

dotnet_naming_symbols.types.applicable_kinds = class, struct, interface, enum
dotnet_naming_symbols.types.applicable_accessibilities = public, internal, private, protected, protected_internal, private_protected

dotnet_naming_symbols.non_field_members.applicable_kinds = property, event, method
dotnet_naming_symbols.non_field_members.applicable_accessibilities = public, internal, private, protected, protected_internal, private_protected

dotnet_naming_symbols.private_or_internal_field.applicable_kinds = field
dotnet_naming_symbols.private_or_internal_field.applicable_accessibilities = internal, private, private_protected

dotnet_naming_style.begins_with_i.required_prefix = I
dotnet_naming_style.begins_with_i.capitalization = pascal_case

dotnet_naming_style.pascal_case.capitalization = pascal_case

dotnet_naming_style.camel_case_with_underscore.required_prefix = _
dotnet_naming_style.camel_case_with_underscore.capitalization = camel_case

dotnet_style_object_initializer = true:suggestion
dotnet_style_collection_initializer = true:suggestion
dotnet_style_explicit_tuple_names = true:suggestion
dotnet_style_coalesce_expression = true:suggestion
dotnet_style_null_propagation = true:suggestion
dotnet_style_prefer_is_null_check_over_reference_equality_method = true:suggestion
dotnet_style_prefer_auto_properties = true:suggestion

csharp_new_line_before_open_brace = all
csharp_new_line_before_else = true
csharp_new_line_before_catch = true
csharp_new_line_before_finally = true

csharp_indent_case_contents = true
csharp_indent_switch_labels = true
csharp_indent_labels = flush_left
```

create file: AJP.KubeExample/Directory.Build.props

```xml
<Project>
    <PropertyGroup>
        <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
        <LangVersion>latest</LangVersion>
        <Nullable>enable</Nullable>
        <ImplicitUsings>enable</ImplicitUsings>
        <Authors>AJP.KubeExample Team</Authors>
        <Version>1.0.0</Version>
        <AssemblyVersion>1.0.0.0</AssemblyVersion>
        <FileVersion>1.0.0.0</FileVersion>
        <RestorePackagesWithLockFile>true</RestorePackagesWithLockFile>
        <GenerateDocumentationFile>true</GenerateDocumentationFile>
        <NoWarn>$(NoWarn);CS1591</NoWarn>
        <Deterministic>true</Deterministic>
        <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
    </PropertyGroup>

    <ItemGroup>
        <PackageReference Include="SonarAnalyzer.CSharp" PrivateAssets="all" />
    </ItemGroup>

    <ItemGroup Condition="'$(MSBuildProjectExtension)' != '.dcproj'">
        <PackageReference Include="StyleCop.Analyzers" PrivateAssets="all" />
    </ItemGroup>
</Project>
```

create file: AJP.KubeExample/Directory.Packages.props

```xml
<Project>
    <PropertyGroup>
        <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
    </PropertyGroup>

    <ItemGroup>
        <PackageVersion Include="Microsoft.AspNetCore.Cors" Version="2.2.0" />
        <PackageVersion Include="Microsoft.Extensions.Configuration" Version="7.0.0" />
        <PackageVersion Include="Microsoft.Extensions.Configuration.Abstractions" Version="7.0.0" />
        <PackageVersion Include="Microsoft.Extensions.DependencyInjection" Version="7.0.0" />
        <PackageVersion Include="Microsoft.Extensions.DependencyInjection.Abstractions" Version="7.0.0" />
        <PackageVersion Include="Microsoft.Extensions.Logging.Abstractions" Version="7.0.0" />
        <PackageVersion Include="Microsoft.Extensions.Options.ConfigurationExtensions" Version="7.0.0" />
        <PackageVersion Include="Microsoft.OpenApi" Version="1.6.9" />

        <PackageVersion Include="Swashbuckle.AspNetCore" Version="6.5.0" />

        <PackageVersion Include="MediatR" Version="12.1.1" />
        <PackageVersion Include="MediatR.Extensions.Microsoft.DependencyInjection" Version="11.1.0" />
        <PackageVersion Include="FluentValidation" Version="11.7.1" />
        <PackageVersion Include="FluentValidation.DependencyInjection" Version="11.7.1" />
        <PackageVersion Include="AutoMapper" Version="12.0.1" />
        <PackageVersion Include="AutoMapper.Extensions.Microsoft.DependencyInjection" Version="12.0.1" />

        <PackageVersion Include="Dapper" Version="2.0.151" />
        <PackageVersion Include="Npgsql" Version="7.0.6" />

        <PackageVersion Include="prometheus-net.AspNetCore" Version="8.0.1" />

        <PackageVersion Include="Microsoft.NET.Test.Sdk" Version="17.7.2" />
        <PackageVersion Include="xunit" Version="2.5.0" />
        <PackageVersion Include="xunit.runner.visualstudio" Version="2.5.0" />
        <PackageVersion Include="Moq" Version="4.20.69" />
        <PackageVersion Include="FluentAssertions" Version="6.12.0" />

        <PackageVersion Include="SonarAnalyzer.CSharp" Version="9.12.0.78982" />
        <PackageVersion Include="StyleCop.Analyzers" Version="1.1.118" />
    </ItemGroup>

    <ItemGroup Condition="'$(MSBuildProjectExtension)' == '.dcproj'">
        <PackageVersion Remove="@(PackageVersion)" />
    </ItemGroup>
</Project>
```

create (run) command to create the solution

```bash
dotnet new sln -n AJP.KubeExample
```
### 2.2 Create Projects with Standardized Settings

Now let's create the projects with our standardized settings:

```bash
# Create projects for DDD architecture
dotnet new webapi -n AJP.API
dotnet new classlib -n AJP.Domain
dotnet new classlib -n AJP.Application
dotnet new classlib -n AJP.Infrastructure
dotnet new classlib -n AJP.Infrastructure.Persistence
dotnet new xunit -n AJP.UnitTests

# Create the React frontend project
dotnet new react -n AJP.Frontend

# Add projects to the solution
dotnet sln add AJP.API/AJP.API.csproj
dotnet sln add AJP.Domain/AJP.Domain.csproj
dotnet sln add AJP.Application/AJP.Application.csproj
dotnet sln add AJP.Infrastructure/AJP.Infrastructure.csproj
dotnet sln add AJP.Infrastructure.Persistence/AJP.Infrastructure.Persistence.csproj
dotnet sln add AJP.UnitTests/AJP.UnitTests.csproj
dotnet sln add AJP.Frontend/AJP.Frontend.csproj
```

### 2.3 Set Up Project References

```bash
# API dependencies
cd AJP.API
dotnet add reference ../AJP.Application/AJP.Application.csproj
dotnet add reference ../AJP.Infrastructure/AJP.Infrastructure.csproj
dotnet add reference ../AJP.Infrastructure.Persistence/AJP.Infrastructure.Persistence.csproj

# Application layer dependencies
cd ../AJP.Application
dotnet add reference ../AJP.Domain/AJP.Domain.csproj

# Infrastructure dependencies
cd ../AJP.Infrastructure
dotnet add reference ../AJP.Domain/AJP.Domain.csproj
dotnet add reference ../AJP.Application/AJP.Application.csproj

# Persistence dependencies
cd ../AJP.Infrastructure.Persistence
dotnet add reference ../AJP.Domain/AJP.Domain.csproj
dotnet add reference ../AJP.Application/AJP.Application.csproj
```

### 2.3 Add Required NuGet Packages

```bash
# API packages
cd ../AJP.API
dotnet add package Microsoft.AspNetCore.Cors
dotnet add package Microsoft.Extensions.DependencyInjection
dotnet add package Microsoft.Extensions.Configuration
dotnet add package Swashbuckle.AspNetCore

# Application packages
cd ../AJP.Application
dotnet add package MediatR
dotnet add package MediatR.Extensions.Microsoft.DependencyInjection
dotnet add package FluentValidation
dotnet add package AutoMapper
dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection

# Infrastructure packages
cd ../AJP.Infrastructure
dotnet add package Microsoft.Extensions.DependencyInjection.Abstractions
dotnet add package Microsoft.Extensions.Configuration.Abstractions

# Persistence packages (Dapper + PostgreSQL)
cd ../AJP.Infrastructure.Persistence
dotnet add package Dapper
dotnet add package Npgsql
dotnet add package Microsoft.Extensions.Configuration
dotnet add package Microsoft.Extensions.Options.ConfigurationExtensions
```

### 2.4 Set Up Domain Layer

Create the core domain entities, value objects, and domain services:

```bash
cd ../AJP.Domain
mkdir -p Entities
mkdir -p ValueObjects
mkdir -p Exceptions
mkdir -p Events
mkdir -p Interfaces
```

Create a sample entity in `AJP.Domain/Entities/Product.cs`:

```csharp
namespace AJP.Domain.Entities;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
```

### 2.5 Set Up Application Layer with MediatR for CQRS

Create the CQRS structure in the Application layer using MediatR:

```bash
cd ../AJP.Application
mkdir -p Common/Behaviors
mkdir -p Common/Interfaces
mkdir -p Common/Models
mkdir -p Common/Validation
mkdir -p Products/Commands/CreateProduct
mkdir -p Products/Commands/UpdateProduct
mkdir -p Products/Commands/DeleteProduct
mkdir -p Products/Queries/GetProductById
mkdir -p Products/Queries/GetAllProducts
```

First, install the MediatR and FluentValidation packages:

```bash
dotnet add package MediatR
dotnet add package FluentValidation
dotnet add package FluentValidation.DependencyInjection
```

Unlike the custom CQRS implementation, MediatR provides the interfaces we need out of the box:

```csharp
// No need to create custom interfaces
// MediatR provides IRequest<TResponse> for commands and queries
// MediatR provides IRequestHandler<TRequest, TResponse> for handlers
```

Create a repository interface in `AJP.Application/Common/Interfaces/IProductRepository.cs`:

```csharp
using AJP.Domain.Entities;

namespace AJP.Application.Common.Interfaces;

public interface IProductRepository
{
    Task<IEnumerable<Product>> GetAllAsync();
    Task<Product?> GetByIdAsync(int id);
    Task<int> CreateAsync(Product product);
    Task<bool> UpdateAsync(Product product);
    Task<bool> DeleteAsync(int id);
}
```

Create a base response class in `AJP.Application/Common/Models/Result.cs`:

```csharp
namespace AJP.Application.Common.Models;

// Record is perfect for immutable value objects
public record Result<T>
{
    public bool IsSuccess { get; }
    public T? Value { get; }
    public string Error { get; }

    private Result(bool isSuccess, T? value, string error) =>
        (IsSuccess, Value, Error) = (isSuccess, value, error);

    public static Result<T> Success(T value) => new(true, value, string.Empty);
    public static Result<T> Failure(string error) => new(false, default, error);
}
```

Create validation infrastructure in `AJP.Application/Common/Validation/ValidationException.cs`:

```csharp
using FluentValidation.Results;

namespace AJP.Application.Common.Validation;

public class ValidationException : Exception
{
    public ValidationException()
        : base("One or more validation failures have occurred.")
    {
        Errors = new Dictionary<string, string[]>();
    }

    public ValidationException(IEnumerable<ValidationFailure> failures)
        : this()
    {
        Errors = failures
            .GroupBy(e => e.PropertyName, e => e.ErrorMessage)
            .ToDictionary(failureGroup => failureGroup.Key, failureGroup => failureGroup.ToArray());
    }

    public IDictionary<string, string[]> Errors { get; }
}
```

Now, let's create a validation behavior for MediatR in `AJP.Application/Common/Behaviors/ValidationBehavior.cs`:

```csharp
using FluentValidation;
using MediatR;

namespace AJP.Application.Common.Behaviors;

// Using primary constructor
public class ValidationBehavior<TRequest, TResponse>(IEnumerable<IValidator<TRequest>> validators) 
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        if (validators.Any())
        {
            var context = new ValidationContext<TRequest>(request);

            var validationResults = await Task.WhenAll(
                validators.Select(v =>
                    v.ValidateAsync(context, cancellationToken)));

            var failures = validationResults
                .SelectMany(r => r.Errors)
                .Where(f => f != null)
                .ToList();

            if (failures.Count != 0)
                throw new Validation.ValidationException(failures);
        }

        return await next();
    }
}
```

Now implement the queries and commands using MediatR:

1. Create the GetAllProducts query in `AJP.Application/Products/Queries/GetAllProducts/GetAllProductsQuery.cs`:

```csharp
using AJP.Domain.Entities;
using MediatR;

namespace AJP.Application.Products.Queries.GetAllProducts;

// Define the query as an IRequest with the expected return type
public record GetAllProductsQuery : IRequest<IEnumerable<Product>>;

// Define the handler for the query with primary constructor
public class GetAllProductsQueryHandler(IProductRepository productRepository) 
    : IRequestHandler<GetAllProductsQuery, IEnumerable<Product>>
{
    // MediatR uses Handle instead of HandleAsync
    public async Task<IEnumerable<Product>> Handle(GetAllProductsQuery query, CancellationToken cancellationToken)
    {
        return await productRepository.GetAllAsync();
    }
}
```

2. Create the GetProductById query in `AJP.Application/Products/Queries/GetProductById/GetProductByIdQuery.cs`:

```csharp
using AJP.Application.Common.Interfaces;
using AJP.Application.Common.Models;
using AJP.Domain.Entities;
using MediatR;

namespace AJP.Application.Products.Queries.GetProductById;

// Define the query with primary constructor for the product ID
public record GetProductByIdQuery(int Id) : IRequest<Result<Product>>;

// Define the handler for the query with primary constructor
public class GetProductByIdQueryHandler(IProductRepository productRepository) 
    : IRequestHandler<GetProductByIdQuery, Result<Product>>
{
    public async Task<Result<Product>> Handle(GetProductByIdQuery query, CancellationToken cancellationToken)
    {
        var product = await productRepository.GetByIdAsync(query.Id);
        
        if (product == null)
            return Result<Product>.Failure($"Product with ID {query.Id} not found.");
            
        return Result<Product>.Success(product);
    }
}
```

3. Create the CreateProduct command in `AJP.Application/Products/Commands/CreateProduct/CreateProductCommand.cs`:

```csharp
using AJP.Domain.Entities;
using FluentValidation;
using MediatR;

namespace AJP.Application.Products.Commands.CreateProduct;

// Define the command with primary constructor and the expected return type
public record CreateProductCommand(
    string Name,
    string Description,
    decimal Price) : IRequest<int>;

// Define the validator for the command
public class CreateProductCommandValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(v => v.Name)
            .NotEmpty().WithMessage("Name is required.")
            .MaximumLength(100).WithMessage("Name must not exceed 100 characters.");
            
        RuleFor(v => v.Price)
            .GreaterThan(0).WithMessage("Price must be greater than 0.");
    }
}

// Define the handler for the command with primary constructor
public class CreateProductCommandHandler(IProductRepository productRepository)
    : IRequestHandler<CreateProductCommand, int>
{
    public async Task<int> Handle(CreateProductCommand command, CancellationToken cancellationToken)
    {
        var product = new Product
        {
            Name = command.Name,
            Description = command.Description,
            Price = command.Price,
            CreatedAt = DateTime.UtcNow
        };

        return await productRepository.CreateAsync(product);
    }
}
```

4. Create the UpdateProduct command in `AJP.Application/Products/Commands/UpdateProduct/UpdateProductCommand.cs`:

```csharp
using AJP.Application.Common.Interfaces;
using AJP.Application.Common.Models;
using AJP.Domain.Entities;
using FluentValidation;
using MediatR;

namespace AJP.Application.Products.Commands.UpdateProduct;

// Using record with primary constructor
public record UpdateProductCommand(
    int Id,
    string Name,
    string Description,
    decimal Price) : IRequest<Result<bool>>;

public class UpdateProductCommandValidator : AbstractValidator<UpdateProductCommand>
{
    public UpdateProductCommandValidator()
    {
        RuleFor(v => v.Id)
            .GreaterThan(0).WithMessage("Id must be greater than 0.");
            
        RuleFor(v => v.Name)
            .NotEmpty().WithMessage("Name is required.")
            .MaximumLength(100).WithMessage("Name must not exceed 100 characters.");
            
        RuleFor(v => v.Price)
            .GreaterThan(0).WithMessage("Price must be greater than 0.");
    }
}

// Using primary constructor
public class UpdateProductCommandHandler(IProductRepository productRepository)
    : IRequestHandler<UpdateProductCommand, Result<bool>>
{
    public async Task<Result<bool>> Handle(UpdateProductCommand command, CancellationToken cancellationToken)
    {
        var product = new Product
        {
            Id = command.Id,
            Name = command.Name,
            Description = command.Description,
            Price = command.Price,
            UpdatedAt = DateTime.UtcNow
        };

        var success = await productRepository.UpdateAsync(product);

        if (!success)
            return Result<bool>.Failure($"Product with ID {command.Id} not found.");
            
        return Result<bool>.Success(true);
    }
}
```

5. Create the DeleteProduct command in `AJP.Application/Products/Commands/DeleteProduct/DeleteProductCommand.cs`:

```csharp
using AJP.Application.Common.Interfaces;
using AJP.Application.Common.Models;
using FluentValidation;
using MediatR;

namespace AJP.Application.Products.Commands.DeleteProduct;

// Using record with primary constructor
public record DeleteProductCommand(int Id) : IRequest<Result<bool>>;

public class DeleteProductCommandValidator : AbstractValidator<DeleteProductCommand>
{
    public DeleteProductCommandValidator()
    {
        RuleFor(v => v.Id)
            .GreaterThan(0).WithMessage("Id must be greater than 0.");
    }
}

// Using primary constructor
public class DeleteProductCommandHandler(IProductRepository productRepository)
    : IRequestHandler<DeleteProductCommand, Result<bool>>
{
    public async Task<Result<bool>> Handle(DeleteProductCommand command, CancellationToken cancellationToken)
    {
        var success = await productRepository.DeleteAsync(command.Id);

        if (!success)
            return Result<bool>.Failure($"Product with ID {command.Id} not found.");
            
        return Result<bool>.Success(true);
    }
}
```

6. Finally, register MediatR and the services in `AJP.Application/DependencyInjection.cs`:

```csharp
using System.Reflection;
using AJP.Application.Common.Behaviors;
using FluentValidation;
using MediatR;
using Microsoft.Extensions.DependencyInjection;

namespace AJP.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        // Register MediatR
        services.AddMediatR(cfg => 
        {
            cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
            
            // Add validation behavior to the pipeline
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        });
        
        // Register validators
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());
        
        return services;
    }
}

```

### 2.6 Update Infrastructure.Persistence Layer for CQRS

Now we need to implement the repository interface in the Infrastructure.Persistence layer to work with our Channels-based CQRS implementation:

```bash
cd ../AJP.Infrastructure.Persistence
```

Update the `ProductRepository.cs` file to implement the interface from the Application layer:

```csharp
using System.Data;
using AJP.Application.Common.Interfaces;
using AJP.Domain.Entities;
using Dapper;
using Microsoft.Extensions.Logging;

namespace AJP.Infrastructure.Persistence.Repositories;

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
        try
        {
            const string sql = "SELECT * FROM Products ORDER BY Id";
            return await _dbConnection.QueryAsync<Product>(sql);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving products");
            return Enumerable.Empty<Product>();
        }
    }

    public async Task<Product?> GetByIdAsync(int id)
    {
        try
        {
            const string sql = "SELECT * FROM Products WHERE Id = @Id";
            return await _dbConnection.QueryFirstOrDefaultAsync<Product>(sql, new { Id = id });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving product with ID {ProductId}", id);
            return null;
        }
    }

    public async Task<int> CreateAsync(Product product)
    {
        try
        {
            const string sql = @"
                INSERT INTO Products (Name, Description, Price, CreatedAt) 
                VALUES (@Name, @Description, @Price, @CreatedAt) 
                RETURNING Id";
                
            return await _dbConnection.ExecuteScalarAsync<int>(sql, product);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating product {ProductName}", product.Name);
            return -1;
        }
    }

    public async Task<bool> UpdateAsync(Product product)
    {
        try
        {
            const string sql = @"
                UPDATE Products 
                SET Name = @Name, 
                    Description = @Description, 
                    Price = @Price, 
                    UpdatedAt = @UpdatedAt
                WHERE Id = @Id";
                
            var rowsAffected = await _dbConnection.ExecuteAsync(sql, product);
            return rowsAffected > 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating product with ID {ProductId}", product.Id);
            return false;
        }
    }

    public async Task<bool> DeleteAsync(int id)
    {
        try
        {
            const string sql = "DELETE FROM Products WHERE Id = @Id";
            var rowsAffected = await _dbConnection.ExecuteAsync(sql, new { Id = id });
            return rowsAffected > 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting product with ID {ProductId}", id);
            return false;
        }
    }
}
```

### 2.7 Update API Layer to Use CQRS with MediatR

Now we'll update the API layer to use our MediatR-based CQRS implementation:

```bash
cd ../AJP.API
```

Update `Program.cs` to register the Application and Infrastructure services:

```csharp
using AJP.Application;
using AJP.Application.Products.Commands.CreateProduct;
using AJP.Application.Products.Commands.DeleteProduct;
using AJP.Application.Products.Commands.UpdateProduct;
using AJP.Application.Products.Queries.GetAllProducts;
using AJP.Application.Products.Queries.GetProductById;
using AJP.Infrastructure;
using AJP.Infrastructure.Persistence;
using MediatR;
using FluentValidation;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register application layer
builder.Services.AddApplication();

// Register infrastructure layer
builder.Services.AddInfrastructure(builder.Configuration);
builder.Services.AddPersistence(builder.Configuration);

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Group endpoints by feature
var productsGroup = app.MapGroup("/products")
    .WithTags("Products")
    .WithOpenApi();

productsGroup.MapGet("/", async (IMediator mediator) =>
    {
        var products = await mediator.Send(new GetAllProductsQuery());
        return Results.Ok(products);
    })
    .WithName("GetAllProducts");

productsGroup.MapGet("/{id}", async (int id, IMediator mediator) =>
    {
        var result = await mediator.Send(new GetProductByIdQuery(id));
        return result.IsSuccess 
            ? Results.Ok(result.Value) 
            : Results.NotFound(result.Error);
    })
    .WithName("GetProductById");

productsGroup.MapPost("/", async (CreateProductCommand command, IMediator mediator) =>
    {
        try
        {
            var id = await mediator.Send(command);
            return Results.Created($"/products/{id}", id);
        }
        catch (ValidationException ex)
        {
            return Results.BadRequest(ex.Errors);
        }
    })
    .WithName("CreateProduct");

productsGroup.MapPut("/{id}", async (int id, UpdateProductCommand command, IMediator mediator) =>
    {
        if (id != command.Id)
            return Results.BadRequest("ID in URL does not match ID in request body");
            
        try
        {
            var result = await mediator.Send(command);
            
            if (!result.IsSuccess)
                return Results.NotFound(result.Error);
                
            return Results.NoContent();
        }
        catch (ValidationException ex)
        {
            return Results.BadRequest(ex.Errors);
        }
    })
    .WithName("UpdateProduct");

productsGroup.MapDelete("/{id}", async (int id, IMediator mediator) =>
    {
        var command = new DeleteProductCommand(id);
        var result = await mediator.Send(command);
        
        if (!result.IsSuccess)
            return Results.NotFound(result.Error);
            
        return Results.NoContent();
    })
    .WithName("DeleteProduct");

app.Run();
```

### 2.8 Database Migration with Flyway

To handle database migrations in a clean, version-controlled way, we'll use Flyway in our Kubernetes environment.

#### 2.8.1 Set Up Flyway in DevSpace

Update your `devspace.yaml` to include Flyway:

```yaml
deployments:
  # Existing deployments...
  
  flyway:
    helm:
      values:
        containers:
          - name: flyway
            image: flyway/flyway:9.21
            command: ["sleep", "infinity"]
            volumeMounts:
              - name: migrations
                mountPath: /flyway/sql
        volumes:
          - name: migrations
            hostPath:
              path: ./AJP.Infrastructure.Persistence/Migrations
```

#### 2.8.2 Create Migration Directory

```bash
mkdir -p AJP.Infrastructure.Persistence/Migrations
```

#### 2.8.3 Create Initial Migration

Create your first migration file in `AJP.Infrastructure.Persistence/Migrations/V1__Initial_Schema.sql`:

```sql
CREATE TABLE IF NOT EXISTS Products (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Price DECIMAL(18,2) NOT NULL,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP NULL
);

-- Add some test data
INSERT INTO Products (Name, Description, Price, CreatedAt)
VALUES ('Test Product 1', 'Description for test product 1', 19.99, CURRENT_TIMESTAMP),
       ('Test Product 2', 'Description for test product 2', 29.99, CURRENT_TIMESTAMP)
ON CONFLICT (Id) DO NOTHING;
```

#### 2.8.4 VS Code Tasks for Flyway

Create a `.vscode/tasks.json` file to simplify working with migrations:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Flyway: Apply Migrations",
      "type": "shell",
      "command": "kubectl exec -i $(kubectl get pods -l app.kubernetes.io/component=postgres -o jsonpath='{.items[0].metadata.name}') -- flyway -url=jdbc:postgresql://localhost:5432/ajp_db -user=postgres -password=${input:dbPassword} migrate",
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "new"
      },
      "group": "none"
    },
    {
      "label": "Flyway: Validate Migrations",
      "type": "shell",
      "command": "kubectl exec -i $(kubectl get pods -l app.kubernetes.io/component=postgres -o jsonpath='{.items[0].metadata.name}') -- flyway -url=jdbc:postgresql://localhost:5432/ajp_db -user=postgres -password=${input:dbPassword} validate",
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "new"
      },
      "group": "none"
    },
    {
      "label": "Flyway: Undo Last Migration",
      "type": "shell",
      "command": "kubectl exec -i $(kubectl get pods -l app.kubernetes.io/component=postgres -o jsonpath='{.items[0].metadata.name}') -- flyway -url=jdbc:postgresql://localhost:5432/ajp_db -user=postgres -password=${input:dbPassword} undo",
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "new"
      },
      "group": "none"
    },
    {
      "label": "Flyway: Show Migration Info",
      "type": "shell",
      "command": "kubectl exec -i $(kubectl get pods -l app.kubernetes.io/component=postgres -o jsonpath='{.items[0].metadata.name}') -- flyway -url=jdbc:postgresql://localhost:5432/ajp_db -user=postgres -password=${input:dbPassword} info",
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "new"
      },
      "group": "none"
    },
    {
      "label": "Flyway: Create New Migration",
      "type": "shell",
      "command": "echo \"-- V$(date +%Y%m%d%H%M%S)__${input:migrationName}.sql\n\n-- Write your migration SQL here\" > ./AJP.Infrastructure.Persistence/Migrations/V$(date +%Y%m%d%H%M%S)__${input:migrationName}.sql && code ./AJP.Infrastructure.Persistence/Migrations/V$(date +%Y%m%d%H%M%S)__${input:migrationName}.sql",
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "new"
      },
      "group": "none"
    }
  ],
  "inputs": [
    {
      "id": "dbPassword",
      "description": "Database password:",
      "default": "postgres",
      "type": "promptString"
    },
    {
      "id": "migrationName",
      "description": "Migration name (use_underscores):",
      "default": "new_migration",
      "type": "promptString"
    }
  ]
}
```

#### 2.8.5 Managing Database Migrations with VS Code Tasks

These VS Code tasks make migration management simple:

1. **Apply Migrations**: Press `Ctrl+Shift+P`, type "Tasks: Run Task", select "Flyway: Apply Migrations"
   - This applies all pending migrations to the database

2. **Validate Migrations**: Run the "Flyway: Validate Migrations" task
   - Checks if migrations will apply cleanly without actually applying them

3. **Undo Last Migration**: Run the "Flyway: Undo Last Migration" task
   - Reverts the most recent migration using undo scripts

4. **Show Migration Info**: Run the "Flyway: Show Migration Info" task
   - Shows which migrations have been applied and which are pending

5. **Create New Migration**: Run the "Flyway: Create New Migration" task
   - Prompts for a migration name and creates a timestamped SQL file
   - Automatically opens the new file in VS Code for editing

#### 2.8.6 Creating a Migration

1. Run the "Flyway: Create New Migration" task
2. Enter a descriptive name like "add_user_table"
3. Write your migration SQL in the opened file
4. Run "Flyway: Apply Migrations" to apply it

#### 2.8.7 Rolling Back a Migration

To support rollbacks, create undo scripts with the same version number:

1. Create a file in `AJP.Infrastructure.Persistence/Migrations/undo/U{version}__{Description}.sql`
2. Run the "Flyway: Undo Last Migration" task

#### 2.8.8 Testing the CQRS Implementation

With migrations set up, test your CQRS implementation:

```bash
# Get all products
curl -X GET http://localhost:5000/products

# Get a specific product
curl -X GET http://localhost:5000/products/1

# Create a new product
curl -X POST http://localhost:5000/products \
  -H "Content-Type: application/json" \
  -d '{"name":"New Product", "description":"A new product", "price":39.99}'

# Update a product
curl -X PUT http://localhost:5000/products/1 \
  -H "Content-Type: application/json" \
  -d '{"id":1, "name":"Updated Product", "description":"An updated product", "price":49.99}'

# Delete a product
curl -X DELETE http://localhost:5000/products/1
```

### 3.4 Implementing CQRS in Larger Applications

For larger applications, the CQRS pattern can be extended with additional features:

#### 3.4.1 Using DTOs with Mapster

In complex domains, you might want to separate your command/query models from your domain entities. Mapster provides a faster, simpler alternative to AutoMapper:

```bash
cd AJP.Application
dotnet add package Mapster
dotnet add package Mapster.DependencyInjection
```

Create DTOs in `AJP.Application/Products/Queries/GetAllProducts/ProductDto.cs`:

```csharp
namespace AJP.Application.Products.Queries.GetAllProducts;

// Perfect use case for a record - immutable data transfer object
public record ProductDto(
    int Id,
    string Name,
    string Description,
    decimal Price,
    DateTime CreatedAt);
```

Configure Mapster in `AJP.Application/Common/Mappings/MappingConfig.cs`:

```csharp
using AJP.Application.Products.Queries.GetAllProducts;
using AJP.Domain.Entities;
using Mapster;

namespace AJP.Application.Common.Mappings;

public static class MappingConfig
{
    public static void Configure()
    {
        // Basic mapping configuration
        TypeAdapterConfig<Product, ProductDto>.NewConfig()
            .Map(dest => dest.Name, src => src.Name)
            .Map(dest => dest.Description, src => src.Description)
            .Map(dest => dest.Price, src => src.Price);

        // You can add more complex mappings or transformations here
        // For example:
        // .Map(dest => dest.FormattedPrice, src => $"${src.Price:0.00}");
    }
}
```

Update the query handler to use Mapster:

```csharp
using AJP.Application.Common.Interfaces;
using AJP.Domain.Entities;
using Mapster;
using MediatR;

namespace AJP.Application.Products.Queries.GetAllProducts;

public record GetAllProductsQuery : IRequest<IEnumerable<ProductDto>>;

// Using primary constructor
public class GetAllProductsQueryHandler(IProductRepository productRepository)
    : IRequestHandler<GetAllProductsQuery, IEnumerable<ProductDto>>
{
    public async Task<IEnumerable<ProductDto>> Handle(GetAllProductsQuery request, CancellationToken cancellationToken)
    {
        var products = await productRepository.GetAllAsync();
        return products.Adapt<IEnumerable<ProductDto>>();
    }
}
```

Register Mapster in `DependencyInjection.cs`:

```csharp
using AJP.Application.Common.Mappings;
using Mapster;
using MapsterMapper;
using System.Reflection;

public static IServiceCollection AddApplication(this IServiceCollection services)
{
    // Configure and register Mapster
    MappingConfig.Configure();
    services.AddSingleton(TypeAdapterConfig.GlobalSettings);
    services.AddScoped<IMapper, ServiceMapper>();
    
    // Other registrations
    services.AddMediatR(cfg => 
    {
        cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
        cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
    });
    
    services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());
    
    return services;
}
```

#### 3.4.2 Adding Logging Behavior

You can add a logging behavior to log all requests and responses:

```csharp
using MediatR;
using Microsoft.Extensions.Logging;

namespace AJP.Application.Common.Behaviors;

// Using primary constructor
public class LoggingBehavior<TRequest, TResponse>(ILogger<LoggingBehavior<TRequest, TResponse>> logger) 
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        var requestName = typeof(TRequest).Name;
        
        logger.LogInformation("Handling {RequestName}", requestName);
        logger.LogDebug("Request details: {@Request}", request);
        
        var response = await next();
        
        logger.LogInformation("Handled {RequestName}", requestName);
        
        return response;
    }
}
```

Register this behavior in `DependencyInjection.cs`:

```csharp
services.AddMediatR(cfg => 
{
    cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(LoggingBehavior<,>));
});
```

#### 3.4.3 Adding Caching with CQRS

For read-heavy applications, you can add caching to your queries:

```bash
cd AJP.Application
dotnet add package Microsoft.Extensions.Caching.Abstractions
```

Create an interface for cacheable queries:

```csharp
namespace AJP.Application.Common.Interfaces;

public interface ICacheableQuery
{
    string CacheKey { get; }
    int CacheTime { get; } // Minutes
}
```

Create a cache behavior:

```csharp
using AJP.Application.Common.Interfaces;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace AJP.Application.Common.Behaviors;

// Using primary constructor
public class CachingBehavior<TRequest, TResponse>(IMemoryCache cache) 
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>, ICacheableQuery
{
    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        var cacheKey = $"{typeof(TRequest).Name}_{request.CacheKey}";
        
        if (cache.TryGetValue(cacheKey, out TResponse cachedResponse))
        {
            return cachedResponse;
        }
        
        var response = await next();
        
        cache.Set(cacheKey, response, TimeSpan.FromMinutes(request.CacheTime));
        
        return response;
    }
}
```

Update a query to use caching:

```csharp
using AJP.Application.Common.Interfaces;
using MediatR;

// Record with implementing interface
public record GetAllProductsQuery : IRequest<IEnumerable<ProductDto>>, ICacheableQuery
{
    public string CacheKey => "AllProducts";
    public int CacheTime => 5; // Minutes
}
```

Register the cache behavior in `DependencyInjection.cs`:

```csharp
services.AddMemoryCache();
services.AddMediatR(cfg => 
{
    cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(LoggingBehavior<,>));
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(CachingBehavior<,>));
});
```


## 4. Integrating CQRS with DevSpace in Kubernetes

Now that we have implemented CQRS in our application, let's see how it works within our DevSpace and Kubernetes environment:

### 4.1 Configure DevSpace for CQRS

Update your `devspace.yaml` file to reflect the new CQRS implementation:

```yaml
# No changes needed for CQRS specifically, but ensure proper environment variables
dev:
  api:
    # ... existing config ...
    env:
      - name: ASPNETCORE_ENVIRONMENT
        value: Development
      - name: ConnectionStrings__DefaultConnection
        value: "Host=postgres;Port=5432;Database=ajp_db;Username=postgres;Password=postgres"
      - name: Logging__LogLevel__Default
        value: "Information"
      - name: Logging__LogLevel__Microsoft
        value: "Warning"
      - name: Logging__LogLevel__Microsoft.Hosting.Lifetime
        value: "Information"
```

### 4.2 Setting Up Monitoring for CQRS

For a real-world CQRS application, monitoring becomes important. You can add some basic monitoring with Prometheus and Grafana:

```bash
# Install Prometheus and Grafana in your cluster
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml
```

Add metrics to your application:

```bash
cd AJP.API
dotnet add package prometheus-net.AspNetCore
```

Update your Program.cs to expose metrics:

```csharp
// Add to your services
builder.Services.AddHealthChecks();

// Add to your middleware pipeline
app.UseMetricServer();
app.UseHttpMetrics();

app.MapHealthChecks("/health");
```

### 4.3 Benefits of CQRS in Kubernetes

CQRS provides several advantages in a Kubernetes environment:

1. **Scalability**: You can scale read and write operations independently
   - Deploy query handlers in multiple pods optimized for reads
   - Deploy command handlers in fewer pods focused on write consistency

2. **Resilience**: Separate failure domains for reads and writes
   - Read failures don't affect write capabilities
   - Write failures don't prevent users from reading data

3. **Resource Optimization**: Different resource profiles
   - Query pods can be optimized for memory and CPU
   - Command pods can be optimized for I/O and consistency

4. **Monitoring Granularity**: Better observability
   - Track command vs. query performance separately
   - Identify bottlenecks more precisely

### 4.4 Testing CQRS in Kubernetes

Verify your CQRS implementation by testing the endpoints in your Kubernetes environment:

```bash
# Start your application with DevSpace
devspace dev

# Get all products (Query)
curl -X GET http://localhost:5000/products

# Create a new product (Command)
curl -X POST http://localhost:5000/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Kubernetes Product", "description":"Created in Kubernetes", "price":99.99}'

# Verify the product was created (Query)
curl -X GET http://localhost:5000/products
```

## 5. Understanding the Code Quality Setup

The project includes several code quality tools and standardization configurations:

### 5.1 EditorConfig for Consistent Formatting

The `.editorconfig` file ensures consistent code formatting across all developer environments and IDEs that support it.

Key benefits:
- Consistent indentation, line endings, and whitespace
- Standard C# naming conventions
- Customized code style settings
- IDE-agnostic formatting rules

### 5.2 Directory.Build.props for Common Build Properties

The `Directory.Build.props` file centralizes common build properties and analyzer settings for all projects:

```xml
<Project>
  <PropertyGroup>
    <!-- Enable treating warnings as errors -->
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    
    <!-- Enable latest C# features -->
    <LangVersion>latest</LangVersion>
    
    <!-- Enable nullable reference types -->
    <Nullable>enable</Nullable>
    
    <!-- Additional shared properties -->
    <!-- ... -->
  </PropertyGroup>
  
  <!-- Common package references for all projects -->
  <ItemGroup>
    <PackageReference Include="SonarAnalyzer.CSharp" PrivateAssets="all" />
  </ItemGroup>

  <!-- Exclude .dcproj files from certain settings -->
  <ItemGroup Condition="'$(MSBuildProjectExtension)' != '.dcproj'">
    <PackageReference Include="StyleCop.Analyzers" PrivateAssets="all" />
  </ItemGroup>
</Project>
```

Key benefits:
- Consistent compiler settings across all projects
- Uniform error handling (TreatWarningsAsErrors)
- Static code analysis for all projects
- Simplified project files by centralizing common settings

### 5.3 Directory.Packages.props for Centralized Package Management

The `Directory.Packages.props` file centralizes all NuGet package versions, ensuring consistency across projects:

```xml
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>

  <!-- Common package versions for all projects -->
  <ItemGroup>
    <!-- Package versions here -->
    <PackageVersion Include="MediatR" Version="12.1.1" />
    <PackageVersion Include="Dapper" Version="2.0.151" />
    <!-- ... -->
  </ItemGroup>

  <!-- Exclude .dcproj files from central package management -->
  <ItemGroup Condition="'$(MSBuildProjectExtension)' == '.dcproj'">
    <PackageVersion Remove="@(PackageVersion)" />
  </ItemGroup>
</Project>
```

Key benefits:
- Single source of truth for package versions
- Simplified dependency updates
- Prevention of version conflicts
- Exclusion of Docker project files (.dcproj) from central management

### 5.4 SonarAnalyzer for Static Code Analysis

SonarAnalyzer is included in all projects through Directory.Build.props and provides:

- Detection of code smells
- Security vulnerability scanning
- Bug detection
- Code maintainability analysis
- Performance issue identification

The analyzer runs during compilation to provide immediate feedback.

### 5.5 Best Practices for Development

When working with this setup:

1. **Honor the EditorConfig**: Ensure your IDE respects the .editorconfig settings

2. **Add new packages to Directory.Packages.props**: 
   ```xml
   <PackageVersion Include="NewPackage" Version="1.0.0" />
   ```

3. **Reference packages in project files without versions**:
   ```xml
   <ItemGroup>
     <PackageReference Include="NewPackage" />
   </ItemGroup>
   ```

4. **Address all warnings**: Since TreatWarningsAsErrors is enabled, all warnings will block the build

5. **Run SonarQube analysis regularly**:
   ```bash
   dotnet sonarscanner begin /k:"project-key" /d:sonar.host.url="http://your-sonar-host"
   dotnet build
   dotnet sonarscanner end
   ```

This code quality setup ensures consistent, maintainable, and high-quality code across the entire project, with minimal configuration needed for individual project files.

## 6. Conclusion

Create a service to call the API in `AJP.Frontend/src/services/api.js`:

```javascript
import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

export const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

export const productService = {
  getAll: async () => {
    try {
      const response = await apiClient.get('/api/products');
      return response.data;
    } catch (error) {
      console.error('Error fetching products:', error);
      throw error;
    }
  },
  
  getById: async (id) => {
    try {
      const response = await apiClient.get(`/api/products/${id}`);
      return response.data;
    } catch (error) {
      console.error(`Error fetching product with id ${id}:`, error);
      throw error;
    }
  },
  
  create: async (product) => {
    try {
      const response = await apiClient.post('/api/products', product);
      return response.data;
    } catch (error) {
      console.error('Error creating product:', error);
      throw error;
    }
  },
  
  update: async (id, product) => {
    try {
      await apiClient.put(`/api/products/${id}`, product);
    } catch (error) {
      console.error(`Error updating product with id ${id}:`, error);
      throw error;
    }
  },
  
  delete: async (id) => {
    try {
      await apiClient.delete(`/api/products/${id}`);
    } catch (error) {
      console.error(`Error deleting product with id ${id}:`, error);
      throw error;
    }
  }
};
```


## 3. Creating the Development Deployments with DevSpace

Now we'll use DevSpace to deploy our DDD solution with PostgreSQL to Kubernetes.

### 3.1 Initialize DevSpace in the Project

```bash
cd AJP.KubeExample
devspace init
```

This will start an interactive wizard. When prompted:
1. Select "Create a new DevSpace project"
2. Choose "Microservices / Multiple Deployments" 
3. Let DevSpace detect your Docker images or enter your own

### 3.2 Configure DevSpace for Your Project with PostgreSQL

Create or edit the `devspace.yaml` file in your AJP.KubeExample directory:

```yaml
version: v2beta1
name: ajp-kubeexample

vars:
  FRONTEND_IMAGE: ajp-frontend
  API_IMAGE: ajp-api
  POSTGRES_PASSWORD: postgres

deployments:
  frontend:
    helm:
      values:
        containers:
          - name: frontend
            image: ${FRONTEND_IMAGE}
            command: ["npm", "start"]
            env:
              - name: REACT_APP_API_URL
                value: http://localhost:5000
        service:
          ports:
            - port: 3000
  
  api:
    helm:
      values:
        containers:
          - name: api
            image: ${API_IMAGE}
            command: ["dotnet", "watch", "run", "--urls=http://0.0.0.0:5000"]
            env:
              - name: ConnectionStrings__DefaultConnection
                value: "Host=postgres;Port=5432;Database=ajp_db;Username=postgres;Password=${POSTGRES_PASSWORD}"
        service:
          ports:
            - port: 5000
  
  postgres:
    helm:
      values:
        containers:
          - name: postgres
            image: postgres:14
            env:
              - name: POSTGRES_PASSWORD
                value: ${POSTGRES_PASSWORD}
              - name: POSTGRES_DB
                value: ajp_db
            volumeMounts:
              - name: postgres-data
                mountPath: /var/lib/postgresql/data
        volumes:
          - name: postgres-data
            emptyDir: {}
        service:
          ports:
            - port: 5432

dev:
  frontend:
    namespace: default
    labelSelector:
      app.kubernetes.io/component: frontend
    ports:
      - port: 3000
    open:
      - url: http://localhost:3000
    sync:
      - path: ./AJP.Frontend/:/app
        excludePaths:
          - node_modules/
          - build/
    terminal:
      enabled: true
      command: "npm install"
  
  api:
    namespace: default
    labelSelector:
      app.kubernetes.io/component: api
    ports:
      - port: 5000
    open:
      - url: http://localhost:5000/swagger
    sync:
      - path: ./:/app
        excludePaths:
          - .git/
          - AJP.Frontend/node_modules/
          - AJP.Frontend/build/
          - "**/.vs/"
          - "**/bin/"
          - "**/obj/"
    terminal:
      enabled: true
      command: "dotnet restore"
  
  postgres:
    namespace: default
    labelSelector:
      app.kubernetes.io/component: postgres
    ports:
      - port: 5432
```

### 3.3 Create PostgreSQL Database Initialization Scripts

Create a directory for the initialization scripts:

```bash
mkdir -p postgres-init
```

Create a SQL script to initialize your database schema in `postgres-init/init.sql`:

```sql
CREATE TABLE IF NOT EXISTS Products (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Price DECIMAL(18, 2) NOT NULL,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP NULL
);

-- Insert some sample data
INSERT INTO Products (Name, Description, Price, CreatedAt)
VALUES 
    ('Product 1', 'Description for product 1', 19.99, CURRENT_TIMESTAMP),
    ('Product 2', 'Description for product 2', 29.99, CURRENT_TIMESTAMP),
    ('Product 3', 'Description for product 3', 39.99, CURRENT_TIMESTAMP);
```

### 3.4 Initialize the Database when Starting Development

Update the DevSpace configuration to include database initialization. Add the following to your `devspace.yaml`:

```yaml
hooks:
  - name: "Setup Database"
    events: ["after:deploy:postgres"]
    command: |
      # Wait for PostgreSQL to be ready
      sleep 10
      POSTGRES_POD=$(kubectl get pods -l app.kubernetes.io/component=postgres -o jsonpath='{.items[0].metadata.name}')
      kubectl cp ./postgres-init/init.sql $POSTGRES_POD:/tmp/init.sql
      kubectl exec $POSTGRES_POD -- psql -U postgres -d ajp_db -f /tmp/init.sql
```

### 3.5 Start Development Mode

With this configuration, you can start your development environment with a single command:

```bash
devspace dev
```

This will:
1. Build and deploy your applications and PostgreSQL
2. Initialize the database with your schema and sample data
3. Set up file synchronization
4. Forward ports
5. Open browser windows to your services
6. Create interactive terminal sessions

## 4. Setting Up VS Code Debugging with DevSpace

DevSpace's port forwarding makes debugging much easier. Let's set up VS Code to debug all components.

### 4.1 Install Required VS Code Extensions

- Kubernetes extension
- C# Dev Kit
- JavaScript Debugger
- PostgreSQL extension (for database inspection)

### 4.2 Create VS Code Debug Configuration

Create or edit `.vscode/launch.json` in your AJP.KubeExample directory:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Chrome: AJP.Frontend",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}/AJP.Frontend"
    },
    {
      "name": "AJP.API",
      "type": "coreclr",
      "request": "attach",
      "processId": "${command:pickRemoteProcess}",
      "pipeTransport": {
        "pipeProgram": "devspace",
        "pipeArgs": ["enter", "--label-selector", "app.kubernetes.io/component=api", "--"],
        "debuggerPath": "/vsdbg/vsdbg",
        "pipeCwd": "${workspaceRoot}"
      }
    }
  ]
}
```

### 4.3 Install the .NET Debugger in the Container

For .NET debugging to work, install the VS Code debugger inside the container. With DevSpace, this is simple:

```bash
# Open a terminal in the API container
devspace enter --label-selector app.kubernetes.io/component=api

# In the container, install the debugger
curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg

# Exit the container
exit
```

### 4.4 Set Up PostgreSQL Connection in VS Code

1. Install the PostgreSQL extension for VS Code
2. Add a new connection:
   - Host: localhost
   - Port: 5432 (DevSpace will port-forward this)
   - User: postgres
   - Password: postgres (as set in the DevSpace config)
   - Database: ajp_db

### 4.5 Start Debugging

1. Make sure DevSpace is running: `devspace dev`
2. In VS Code, go to the "Run and Debug" view
3. Select "Chrome: AJP.Frontend" to debug the React application
4. Select "AJP.API" to debug the .NET application

DevSpace keeps the necessary port forwarding active, so you can set breakpoints, inspect variables, and step through code just like in local development.

## 5. Development Workflow with DDD and PostgreSQL

With DevSpace, VS Code, and our DDD architecture set up, here's your optimal development workflow:

### 5.1 Starting Development

```bash
cd AJP.KubeExample
devspace dev
```

This single command:
- Builds all necessary images
- Deploys frontend, API, and PostgreSQL to Kubernetes
- Sets up file synchronization
- Forwards all required ports
- Opens browser tabs for your services
- Initializes the PostgreSQL database with your schema

### 5.2 DDD Development Process with Minimal API

When implementing new features in your DDD architecture with Minimal API:

1. **Start with the Domain Layer**:
   - Define or update entities, value objects, and domain events in the Domain project
   - This layer should be focused on business rules and contain no external dependencies

2. **Implement the Application Layer**:
   - Create command and query handlers for the new feature
   - Define DTOs for transferring data between layers
   - Implement validation and business logic

3. **Update the Infrastructure Layer**:
   - Implement repository interfaces with Dapper
   - Write SQL queries for the new feature
   - Handle data access concerns

4. **Finally, Define Minimal API Endpoints**:
   - Create a new endpoint extension class:
     ```csharp
     // Create MyFeatureEndpoints.cs for feature-specific endpoints
     public static class MyFeatureEndpoints
     {
         public static WebApplication MapMyFeatureEndpoints(this WebApplication app)
         {
             app.MapGet("/api/myfeature", GetMyFeature);
             // Add other endpoints
             return app;
         }
         
         private static async Task<IResult> GetMyFeature(IMyFeatureService service)
         {
             var result = await service.GetDataAsync();
             return Results.Ok(result);
         }
     }
     ```
   - Register in Program.cs: `app.MapMyFeatureEndpoints();`

5. **Update the React Frontend**:
   - Implement UI components to consume the new API
   - Handle state management and user interactions

### 5.3 Advantages of Minimal API in Kubernetes

Minimal API provides several benefits for your Kubernetes-deployed application:

1. **Reduced memory footprint**: 
   - Smaller assemblies
   - Faster startup time
   - More efficient in container environments

2. **Simplified development workflow**:
   - Fewer files to manage
   - Less ceremony compared to controllers
   - Direct dependency injection into endpoint handlers

3. **Better organization with extension methods**:
   - Group related endpoints
   - Maintain clean Program.cs
   - Easier to understand API surface

4. **Improved performance**:
   - Fewer layers of abstraction
   - Optimized request pipeline
   - Lower latency for API calls

### 5.3 Working with PostgreSQL and Dapper

To interact with the database during development:

```bash
# Connect to the database using psql in the container
devspace enter --label-selector app.kubernetes.io/component=postgres
psql -U postgres -d ajp_db

# Or execute SQL directly
devspace enter --label-selector app.kubernetes.io/component=postgres
psql -U postgres -d ajp_db -c "SELECT * FROM Products"
```

For writing efficient Dapper queries:

1. Use parameterized queries to prevent SQL injection
2. Use appropriate Dapper methods:
   - `Query<T>` for multiple rows
   - `QuerySingle<T>` for a single row (throws if not found)
   - `QuerySingleOrDefault<T>` for a single row or null
   - `Execute` for commands (returns affected rows)
   - `ExecuteScalar<T>` for single value returns

3. For complex queries, consider using SQL files:
   ```csharp
   var sql = await File.ReadAllTextAsync("Sql/GetProducts.sql");
   var products = await connection.QueryAsync<Product>(sql, parameters);
   ```

### 5.4 Making Schema Changes

When you need to update your database schema:

1. Update your domain entities
2. Create a migration SQL script in `postgres-init/migrations/`
3. Apply the migration:
   ```bash
   devspace enter --label-selector app.kubernetes.io/component=postgres
   psql -U postgres -d ajp_db -f /tmp/migrations/your-migration.sql
   ```

Or, for easier schema management, consider adding a database migration tool like Flyway to your solution.

### 5.5 Debugging

1. Set breakpoints in VS Code:
   - Domain logic
   - Application services
   - Data access code
   - API controllers

2. Launch the appropriate debug configuration
3. Trigger the code path in your application
4. Use VS Code PostgreSQL extension to examine the database state

### 5.6 Viewing Logs

```bash
# View logs from all services
devspace logs -f

# View logs from just the API
devspace logs -f --label-selector app.kubernetes.io/component=api

# View logs from just the frontend
devspace logs -f --label-selector app.kubernetes.io/component=frontend

# View PostgreSQL logs
devspace logs -f --label-selector app.kubernetes.io/component=postgres
```

### 5.7 Stopping Development

```bash
# Press Ctrl+C in the terminal where devspace dev is running

# Or from another terminal
devspace purge
```

## 6. Cleanup and Resource Management

### 6.1 Temporary Pausing Development

If you want to pause development without removing everything:

```bash
# Stop DevSpace without purging deployments
devspace stop
```

### 6.2 Complete Cleanup

When you're completely done with development:

```bash
# Remove all DevSpace deployments
devspace purge

# Or for a more thorough cleanup
devspace reset pods
```

### 6.3 Checking Resource Usage

```bash
# Check what's running
kubectl get pods,deployments,services

# Check resource usage
kubectl top pods
kubectl top nodes
```

### 6.4 Backing Up PostgreSQL Data

Before shutting down your environment, you might want to back up your database:

```bash
# Export PostgreSQL data to a dump file
devspace enter --label-selector app.kubernetes.io/component=postgres
pg_dump -U postgres ajp_db > /tmp/ajp_db_backup.sql
exit

# Copy the dump file to your local machine
POSTGRES_POD=$(kubectl get pods -l app.kubernetes.io/component=postgres -o jsonpath='{.items[0].metadata.name}')
kubectl cp $POSTGRES_POD:/tmp/ajp_db_backup.sql ./ajp_db_backup.sql
```

## 7. Troubleshooting

### DevSpace Issues

If DevSpace encounters problems:

```bash
# Reset DevSpace cache
devspace reset

# Enable verbose logging
devspace dev --verbose
```

### Image Pull Issues

If you encounter "ImagePullBackOff" errors with DevSpace:

```bash
# Use DevSpace with a local registry
devspace dev --use-docker-hub=false
```

### Network Access Issues

If you can't access services:

1. Check DevSpace port forwarding status:
   ```bash
   devspace list ports
   ```
   
2. Manually set up port forwarding if needed:
   ```bash
   devspace enter --label-selector app.kubernetes.io/component=api
   ```

### PostgreSQL Connection Issues

If your API can't connect to PostgreSQL:

1. Check if PostgreSQL pod is running:
   ```bash
   kubectl get pods -l app.kubernetes.io/component=postgres
   ```

2. Check PostgreSQL logs:
   ```bash
   devspace logs -f --label-selector app.kubernetes.io/component=postgres
   ```

3. Test the connection from within the API container:
   ```bash
   devspace enter --label-selector app.kubernetes.io/component=api
   nc -zv postgres 5432
   ```

4. Verify the connection string in the API container:
   ```bash
   devspace enter --label-selector app.kubernetes.io/component=api
   printenv | grep CONNECTION
   ```

### VS Code Debugging Issues

For .NET debugging:
1. Make sure the debugger is installed in the container
2. Check the pod is running and the app started correctly
3. Verify the DevSpace port-forwarding is active

For React debugging:
1. Make sure the Chrome Debugger extension is installed
2. Check React app is running on the expected port
3. Verify source maps are enabled in your React app

### DDD Architecture Issues

If you encounter issues with your DDD implementation:

1. Ensure proper separation of concerns:
   - Domain layer should not reference other layers
   - Application layer should only reference Domain
   - Infrastructure should not be referenced by Domain or Application
   - API should not contain business logic

2. Check for circular dependencies:
   ```bash
   cd AJP.KubeExample
   dotnet build
   ```
   
3. Verify Dapper queries:
   ```bash
   # Enable Dapper parameter logging
   # Add to your repository constructor:
   SimpleCRUD.SetLogger(s => Console.WriteLine(s));
   ```

## 8. Detailed Configuration for Code Quality and Standardization

To ensure high code quality and consistent standards across the project, we'll use three key configuration files: `.editorconfig`, `Directory.Build.props`, and `Directory.Packages.props`. Here's a detailed breakdown of each:

### 8.1 EditorConfig Configuration

The `.editorconfig` file provides IDE-agnostic code formatting rules. Here's a comprehensive configuration:

```plaintext
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.cs]
# C# specific settings
# Organize usings
dotnet_sort_system_directives_first = true
dotnet_separate_import_directive_groups = false

# Naming conventions
dotnet_naming_rule.interface_should_be_begins_with_i.severity = suggestion
dotnet_naming_rule.interface_should_be_begins_with_i.symbols = interface
dotnet_naming_rule.interface_should_be_begins_with_i.style = begins_with_i

dotnet_naming_rule.types_should_be_pascal_case.severity = suggestion
dotnet_naming_rule.types_should_be_pascal_case.symbols = types
dotnet_naming_rule.types_should_be_pascal_case.style = pascal_case

dotnet_naming_rule.non_field_members_should_be_pascal_case.severity = suggestion
dotnet_naming_rule.non_field_members_should_be_pascal_case.symbols = non_field_members
dotnet_naming_rule.non_field_members_should_be_pascal_case.style = pascal_case

dotnet_naming_rule.private_or_internal_field_should_be_camel_case.severity = suggestion
dotnet_naming_rule.private_or_internal_field_should_be_camel_case.symbols = private_or_internal_field
dotnet_naming_rule.private_or_internal_field_should_be_camel_case.style = camel_case_with_underscore

# Symbol specifications
dotnet_naming_symbols.interface.applicable_kinds = interface
dotnet_naming_symbols.interface.applicable_accessibilities = public, internal, private, protected, protected_internal, private_protected
dotnet_naming_symbols.interface.required_modifiers = 

dotnet_naming_symbols.types.applicable_kinds = class, struct, interface, enum
dotnet_naming_symbols.types.applicable_accessibilities = public, internal, private, protected, protected_internal, private_protected
dotnet_naming_symbols.types.required_modifiers = 

dotnet_naming_symbols.non_field_members.applicable_kinds = property, event, method
dotnet_naming_symbols.non_field_members.applicable_accessibilities = public, internal, private, protected, protected_internal, private_protected
dotnet_naming_symbols.non_field_members.required_modifiers = 

dotnet_naming_symbols.private_or_internal_field.applicable_kinds = field
dotnet_naming_symbols.private_or_internal_field.applicable_accessibilities = internal, private, private_protected
dotnet_naming_symbols.private_or_internal_field.required_modifiers = 

# Naming styles
dotnet_naming_style.begins_with_i.required_prefix = I
dotnet_naming_style.begins_with_i.required_suffix = 
dotnet_naming_style.begins_with_i.word_separator = 
dotnet_naming_style.begins_with_i.capitalization = pascal_case

dotnet_naming_style.pascal_case.required_prefix = 
dotnet_naming_style.pascal_case.required_suffix = 
dotnet_naming_style.pascal_case.word_separator = 
dotnet_naming_style.pascal_case.capitalization = pascal_case

dotnet_naming_style.camel_case_with_underscore.required_prefix = _
dotnet_naming_style.camel_case_with_underscore.required_suffix = 
dotnet_naming_style.camel_case_with_underscore.word_separator = 
dotnet_naming_style.camel_case_with_underscore.capitalization = camel_case

# Expression-level preferences
dotnet_style_object_initializer = true:suggestion
dotnet_style_collection_initializer = true:suggestion
dotnet_style_explicit_tuple_names = true:suggestion
dotnet_style_coalesce_expression = true:suggestion
dotnet_style_null_propagation = true:suggestion
dotnet_style_prefer_is_null_check_over_reference_equality_method = true:suggestion
dotnet_style_prefer_auto_properties = true:suggestion

# New line preferences
csharp_new_line_before_open_brace = all
csharp_new_line_before_else = true
csharp_new_line_before_catch = true
csharp_new_line_before_finally = true

# Indentation preferences
csharp_indent_case_contents = true
csharp_indent_switch_labels = true
csharp_indent_labels = flush_left

[*.{json,yml,yaml,xml,csproj,props,targets}]
indent_size = 2

[*.md]
max_line_length = off
trim_trailing_whitespace = false
```

### 8.2 Directory.Build.props Configuration

The `Directory.Build.props` file centralizes build properties for all projects:

```xml
<Project>
  <PropertyGroup>
    <!-- Enable treating warnings as errors -->
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    
    <!-- Enable latest C# features -->
    <LangVersion>latest</LangVersion>
    
    <!-- Enable nullable reference types -->
    <Nullable>enable</Nullable>
    
    <!-- Enable implicit usings -->
    <ImplicitUsings>enable</ImplicitUsings>
    
    <!-- Set a default author for all assemblies -->
    <Authors>AJP.KubeExample Team</Authors>
    
    <!-- Set consistent versioning -->
    <Version>1.0.0</Version>
    <AssemblyVersion>1.0.0.0</AssemblyVersion>
    <FileVersion>1.0.0.0</FileVersion>
    
    <!-- Force usage of NuGet packages over project references -->
    <RestorePackagesWithLockFile>true</RestorePackagesWithLockFile>
    
    <!-- Generate XML documentation -->
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    
    <!-- Disable CS1591 warnings for missing XML comments -->
    <NoWarn>$(NoWarn);CS1591</NoWarn>
    
    <!-- Enable deterministic builds -->
    <Deterministic>true</Deterministic>
    
    <!-- Use centrally-managed package versions -->
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>
  
  <!-- Common package references for all projects -->
  <ItemGroup>
    <!-- Static code analysis -->
    <PackageReference Include="SonarAnalyzer.CSharp" PrivateAssets="all" />
  </ItemGroup>

  <!-- Exclude .dcproj files from certain settings -->
  <ItemGroup Condition="'$(MSBuildProjectExtension)' != '.dcproj'">
    <PackageReference Include="StyleCop.Analyzers" PrivateAssets="all" />
  </ItemGroup>
</Project>
```

### 8.3 Directory.Packages.props Configuration

The `Directory.Packages.props` file centralizes all package versions:

```xml
<Project>
  <PropertyGroup>
    <!-- Enable central package management -->
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>

  <!-- Common package versions for all projects -->
  <ItemGroup>
    <!-- Microsoft packages -->
    <PackageVersion Include="Microsoft.AspNetCore.Cors" Version="2.2.0" />
    <PackageVersion Include="Microsoft.Extensions.Configuration" Version="7.0.0" />
    <PackageVersion Include="Microsoft.Extensions.Configuration.Abstractions" Version="7.0.0" />
    <PackageVersion Include="Microsoft.Extensions.DependencyInjection" Version="7.0.0" />
    <PackageVersion Include="Microsoft.Extensions.DependencyInjection.Abstractions" Version="7.0.0" />
    <PackageVersion Include="Microsoft.Extensions.Logging.Abstractions" Version="7.0.0" />
    <PackageVersion Include="Microsoft.Extensions.Options.ConfigurationExtensions" Version="7.0.0" />
    <PackageVersion Include="Microsoft.OpenApi" Version="1.6.9" />
    
    <!-- Swagger -->
    <PackageVersion Include="Swashbuckle.AspNetCore" Version="6.5.0" />
    
    <!-- CQRS & Validation -->
    <PackageVersion Include="MediatR" Version="12.1.1" />
    <PackageVersion Include="MediatR.Extensions.Microsoft.DependencyInjection" Version="11.1.0" />
    <PackageVersion Include="FluentValidation" Version="11.7.1" />
    <PackageVersion Include="FluentValidation.DependencyInjection" Version="11.7.1" />
    <PackageVersion Include="AutoMapper" Version="12.0.1" />
    <PackageVersion Include="AutoMapper.Extensions.Microsoft.DependencyInjection" Version="12.0.1" />
    
    <!-- Data Access -->
    <PackageVersion Include="Dapper" Version="2.0.151" />
    <PackageVersion Include="Npgsql" Version="7.0.6" />
    
    <!-- Monitoring -->
    <PackageVersion Include="prometheus-net.AspNetCore" Version="8.0.1" />
    
    <!-- Testing -->
    <PackageVersion Include="Microsoft.NET.Test.Sdk" Version="17.7.2" />
    <PackageVersion Include="xunit" Version="2.5.0" />
    <PackageVersion Include="xunit.runner.visualstudio" Version="2.5.0" />
    <PackageVersion Include="Moq" Version="4.20.69" />
    <PackageVersion Include="FluentAssertions" Version="6.12.0" />
    
    <!-- Code Quality -->
    <PackageVersion Include="SonarAnalyzer.CSharp" Version="9.12.0.78982" />
    <PackageVersion Include="StyleCop.Analyzers" Version="1.1.118" />
  </ItemGroup>

  <!-- Exclude .dcproj files from central package management -->
  <ItemGroup Condition="'$(MSBuildProjectExtension)' == '.dcproj'">
    <PackageVersion Remove="@(PackageVersion)" />
  </ItemGroup>
</Project>
```

### 8.4 Benefits of This Configuration

This standardized configuration provides numerous benefits:

1. **Consistent Code Style**: All developers follow the same formatting rules
2. **Improved Code Quality**: Static analysis with SonarAnalyzer catches issues early
3. **Reduced Build Issues**: TreatWarningsAsErrors ensures clean code
4. **Simplified Dependency Management**: Centralized package versions prevent version conflicts
5. **Streamlined Onboarding**: New developers automatically follow team standards
6. **Better Documentation**: XML documentation is consistently generated
7. **Enhanced CI/CD**: Deterministic builds improve pipeline reliability

### 8.5 Using These Configurations in the Development Workflow

When working with these configurations:

1. **During Development**:
   - IDEs automatically apply formatting rules from .editorconfig
   - Warnings are treated as errors, enforcing high standards
   - SonarAnalyzer provides real-time code quality feedback

2. **Adding New Dependencies**:
   - Always add version to Directory.Packages.props first
   - Reference the package without version in project files
   - Run `dotnet restore` to update dependency locks

3. **Creating New Projects**:
   - Properties from Directory.Build.props are automatically applied
   - Ensures consistency across all projects

4. **During Code Reviews**:
   - Automated checks enforce standards
   - Reviewers can focus on architecture and business logic
   - CI/CD pipelines enforce the same standards

## 9. Modern C# Coding Practices

This project follows modern C# coding practices to make the code more concise, readable, and maintainable:

### 9.1 Records for DTOs and Value Objects

Records are perfect for immutable data structures like DTOs and value objects:

```csharp
// Before (class-based DTO)
public class ProductDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public DateTime CreatedAt { get; set; }
}

// After (record-based DTO)
public record ProductDto(
    int Id,
    string Name, 
    string Description,
    decimal Price,
    DateTime CreatedAt);
```

**Benefits:**
- Built-in value-based equality
- Immutability by default
- Concise syntax
- Built-in deconstruction
- With-expressions for non-destructive mutation

### 9.2 Primary Constructors

Primary constructors reduce boilerplate in classes that need dependency injection:

```csharp
// Before
public class ProductService
{
    private readonly IProductRepository _productRepository;

    public ProductService(IProductRepository productRepository)
    {
        _productRepository = productRepository;
    }
    
    // Methods...
}

// After
public class ProductService(IProductRepository productRepository)
{
    // Methods that use productRepository directly...
}
```

**Benefits:**
- Less boilerplate code
- Parameter directly accessible in method bodies
- Cleaner code with fewer private fields

### 9.3 File-Scoped Namespaces

Using file-scoped namespaces reduces indentation and makes code cleaner:

```csharp
// Before
namespace AJP.Application.Products.Queries
{
    public record GetAllProductsQuery : IRequest<IEnumerable<Product>>;
    
    // Other types...
}

// After
namespace AJP.Application.Products.Queries;

public record GetAllProductsQuery : IRequest<IEnumerable<Product>>;

// Other types...
```

### 9.4 Top-Level Statements

In Program.cs, top-level statements remove boilerplate:

```csharp
// Before
namespace AJP.API
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            // Configuration...
            var app = builder.Build();
            // More code...
            app.Run();
        }
    }
}

// After
var builder = WebApplication.CreateBuilder(args);
// Configuration...
var app = builder.Build();
// More code...
app.Run();
```

### 9.5 Minimal API with Endpoint Groups

Using endpoint groups for better organization:

```csharp
// Group endpoints by feature
var productsGroup = app.MapGroup("/products")
    .WithTags("Products")
    .WithOpenApi();

productsGroup.MapGet("/", async (IMediator mediator) => /* ... */);
productsGroup.MapGet("/{id}", async (int id, IMediator mediator) => /* ... */);
productsGroup.MapPost("/", async (CreateProductCommand command, IMediator mediator) => /* ... */);
```

### 9.6 Pattern Matching

Using modern pattern matching for cleaner code:

```csharp
// Before
if (result.IsSuccess)
{
    return Results.Ok(result.Value);
}
else
{
    return Results.NotFound(result.Error);
}

// After
return result.IsSuccess 
    ? Results.Ok(result.Value) 
    : Results.NotFound(result.Error);
```

### 9.7 Global Using Directives

Using global usings to reduce repetitive imports:

```csharp
// In GlobalUsings.cs
global using System;
global using System.Collections.Generic;
global using System.Threading;
global using System.Threading.Tasks;
global using MediatR;
global using FluentValidation;
```

### 9.8 Init-Only Properties

For more flexibility than records when needed:

```csharp
public class UpdateRequest
{
    public required string Name { get; init; }
    public required decimal Price { get; init; }
}
```

### 9.9 When to Use Each Feature

- **Use records for:** DTOs, value objects, immutable data
- **Use classes for:** Entities with identity, mutable objects, complex behaviors
- **Use primary constructors for:** Handlers, services, behaviors with dependencies
- **Use endpoint groups for:** Related API endpoints
- **Use init-only properties for:** Semi-immutable objects with complex initialization

## 10. Learning Resources
## 9. Conclusion

In this guide, we've set up a complete development environment for a .NET application with:

1. A Kubernetes cluster using kind
2. DevSpace for efficient Kubernetes development
3. A .NET solution with Domain-Driven Design architecture
4. PostgreSQL database integration with Dapper
5. CQRS pattern implementation with MediatR
6. A React frontend with hot reloading
7. Standardized code quality with .editorconfig, Directory.Build.props, and Directory.Packages.props
8. Static code analysis with SonarAnalyzer
9. Strict quality enforcement with TreatWarningsAsErrors

This setup provides a modern, scalable architecture for building complex applications while maintaining a great development experience with hot reloading, efficient workflows, and consistent code quality standards across the team.
