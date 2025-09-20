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
            const string sql = "DELETE FROM Products WHERE Id = @Id";
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