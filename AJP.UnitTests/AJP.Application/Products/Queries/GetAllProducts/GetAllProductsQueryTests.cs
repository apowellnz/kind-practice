using AJP.Application.Common.Interfaces;
using AJP.Application.Products.Queries.GetAllProducts;
using AJP.Domain.Entities;
using Moq;

namespace AJP.UnitTests.AJP.Application.Products.Queries.GetAllProducts;

public class GetAllProductsQueryTests
{
    private readonly Mock<IProductRepository> _mockProductRepository;
    private readonly GetAllProductsQueryHandler _handler;

    public GetAllProductsQueryTests()
    {
        _mockProductRepository = new Mock<IProductRepository>();
        _handler = new GetAllProductsQueryHandler(_mockProductRepository.Object);
    }

    [Fact]
    public async Task Handle_ReturnsAllProducts()
    {
        // Arrange
        var products = new List<Product>
        {
            new Product
            {
                Id = 1,
                Name = "Product 1",
                Description = "Description 1",
                Price = 10.99m
            },
            new Product
            {
                Id = 2,
                Name = "Product 2",
                Description = "Description 2",
                Price = 20.99m
            }
        };

        _mockProductRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(products);
        var query = new GetAllProductsQuery();

        // Act
        IEnumerable<Product> result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(2, result.Count());
        Assert.Equal(products, result);
        _mockProductRepository.Verify(r => r.GetAllAsync(), Times.Once);
    }

    [Fact]
    public async Task Handle_NoProducts_ReturnsEmptyList()
    {
        // Arrange
        var products = new List<Product>();
        _mockProductRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(products);
        var query = new GetAllProductsQuery();

        // Act
        IEnumerable<Product> result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Empty(result);
        _mockProductRepository.Verify(r => r.GetAllAsync(), Times.Once);
    }
}
