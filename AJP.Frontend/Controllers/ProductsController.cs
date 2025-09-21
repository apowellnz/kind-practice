using AJP.Application.Products.Queries.GetAllProducts;
using AJP.Domain.Entities;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace AJP.Frontend.Controllers;

/// <summary>
/// Controller for product data.
/// </summary>
[Route("api/[controller]")]
public class ProductsController : Controller
{
    private readonly IMediator _mediator;
    private readonly ILogger<ProductsController> _logger;

    /// <summary>
    /// Initializes a new instance of the <see cref="ProductsController"/> class.
    /// </summary>
    /// <param name="mediator">The mediator instance.</param>
    /// <param name="logger">The logger instance.</param>
    public ProductsController(IMediator mediator, ILogger<ProductsController> logger)
    {
        _mediator = mediator ?? throw new ArgumentNullException(nameof(mediator));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Gets all products.
    /// </summary>
    /// <returns>A collection of products.</returns>
    [HttpGet("[action]")]
    public async Task<IEnumerable<Product>> GetProducts()
    {
        try
        {
            _logger.LogInformation("Fetching all products");
            return await _mediator.Send(new GetAllProductsQuery());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching products");
            return Enumerable.Empty<Product>();
        }
    }
}
