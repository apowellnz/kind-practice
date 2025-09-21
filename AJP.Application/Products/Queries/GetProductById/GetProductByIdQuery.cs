using AJP.Application.Common.Interfaces;
using AJP.Application.Common.Models;
using AJP.Domain.Entities;
using MediatR;

namespace AJP.Application.Products.Queries.GetProductById;

public record GetProductByIdQuery(int Id) : IRequest<Result<Product>>;

public class GetProductByIdQueryHandler : IRequestHandler<GetProductByIdQuery, Result<Product>>
{
    private readonly IProductRepository _productRepository;

    public GetProductByIdQueryHandler(IProductRepository productRepository)
    {
        _productRepository = productRepository;
    }

    public async Task<Result<Product>> Handle(GetProductByIdQuery request, CancellationToken cancellationToken)
    {
        Product? product = await _productRepository.GetByIdAsync(request.Id);

        if (product == null)
        {
            return Result<Product>.Failure($"Product with ID {request.Id} not found.");
        }

        return Result<Product>.Success(product);
    }
}