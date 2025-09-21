using System.Threading;
using System.Threading.Tasks;
using AJP.Application.Common.Interfaces;
using AJP.Application.Common.Models;
using AJP.Application.Products.Queries.GetProductById;
using AJP.Domain.Entities;
using Moq;

namespace AJP.UnitTests.AJP.Application.Products.Queries.GetProductById;

public class GetProductByIdQueryTests
{
    private readonly Mock<IProductRepository> _mockProductRepository;
    private readonly GetProductByIdQueryHandler _handler;

    public GetProductByIdQueryTests()
    {
        _mockProductRepository = new Mock<IProductRepository>();
        _handler = new GetProductByIdQueryHandler(_mockProductRepository.Object);
    }

    [Fact]
    public async Task Handle_ProductExists_ReturnsSuccessResult()
    {
        // Arrange
        int productId = 1;
        var product = new Product
        {
            Id = productId,
            Name = "Test Product",
            Description = "Test Description",
            Price = 19.99m
        };

        _mockProductRepository.Setup(r => r.GetByIdAsync(productId)).ReturnsAsync(product);
        var query = new GetProductByIdQuery(productId);

        // Act
        Result<Product> result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.True(result.IsSuccess);
        Assert.Equal(product, result.Value);
        _mockProductRepository.Verify(r => r.GetByIdAsync(productId), Times.Once);
    }

    [Fact]
    public async Task Handle_ProductDoesNotExist_ReturnsFailureResult()
    {
        // Arrange
        int productId = 999;
        Product? nullProduct = null;

        _mockProductRepository.Setup(r => r.GetByIdAsync(productId)).ReturnsAsync(nullProduct);
        var query = new GetProductByIdQuery(productId);

        // Act
        Result<Product> result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal($"Product with ID {productId} not found.", result.Error);
        _mockProductRepository.Verify(r => r.GetByIdAsync(productId), Times.Once);
    }
}
