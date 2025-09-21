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
            const string sql = "SELECT id as Id, name as Name, description as Description, price as Price, stock as Stock, created_at as CreatedAt, updated_at as UpdatedAt FROM products ORDER BY id";
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
            const string sql = "SELECT id as Id, name as Name, description as Description, price as Price, stock as Stock, created_at as CreatedAt, updated_at as UpdatedAt FROM products WHERE id = @Id";
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
                INSERT INTO products (name, description, price, stock, created_at) 
                VALUES (@Name, @Description, @Price, @Stock, @CreatedAt) 
                RETURNING id";

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
                UPDATE products 
                SET name = @Name, 
                    description = @Description, 
                    price = @Price, 
                    stock = @Stock,
                    updated_at = @UpdatedAt
                WHERE id = @Id";

            int rowsAffected = await _dbConnection.ExecuteAsync(sql, product);
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
            const string sql = "DELETE FROM products WHERE id = @Id";
            int rowsAffected = await _dbConnection.ExecuteAsync(sql, new { Id = id });
            return rowsAffected > 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting product with ID {ProductId}", id);
            return false;
        }
    }
}