using AJP.Application.Common.Interfaces;
using AJP.Application.Common.Models;
using AJP.Domain.Entities;
using FluentValidation;
using MediatR;

namespace AJP.Application.Products.Commands.UpdateProduct;

public record UpdateProductCommand : IRequest<Result<Unit>>
{
    public int Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public string Description { get; init; } = string.Empty;
    public decimal Price { get; init; }
}

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

public class UpdateProductCommandHandler : IRequestHandler<UpdateProductCommand, Result<Unit>>
{
    private readonly IProductRepository _productRepository;

    public UpdateProductCommandHandler(IProductRepository productRepository)
    {
        _productRepository = productRepository;
    }

    public async Task<Result<Unit>> Handle(UpdateProductCommand request, CancellationToken cancellationToken)
    {
        var product = new Product
        {
            Id = request.Id,
            Name = request.Name,
            Description = request.Description,
            Price = request.Price,
            UpdatedAt = DateTime.UtcNow
        };

        bool success = await _productRepository.UpdateAsync(product);

        if (!success)
        {
            return Result<Unit>.Failure($"Product with ID {request.Id} not found.");
        }


        return Result<Unit>.Success(Unit.Value);
    }
}