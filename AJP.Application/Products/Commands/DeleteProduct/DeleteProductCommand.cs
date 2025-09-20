using AJP.Application.Common.Interfaces;
using AJP.Application.Common.Models;
using FluentValidation;
using MediatR;

namespace AJP.Application.Products.Commands.DeleteProduct;

public record DeleteProductCommand(int Id) : IRequest<Result<Unit>>;

public class DeleteProductCommandValidator : AbstractValidator<DeleteProductCommand>
{
    public DeleteProductCommandValidator()
    {
        RuleFor(v => v.Id)
            .GreaterThan(0).WithMessage("Id must be greater than 0.");
    }
}

public class DeleteProductCommandHandler : IRequestHandler<DeleteProductCommand, Result<Unit>>
{
    private readonly IProductRepository _productRepository;

    public DeleteProductCommandHandler(IProductRepository productRepository)
    {
        _productRepository = productRepository;
    }

    public async Task<Result<Unit>> Handle(DeleteProductCommand request, CancellationToken cancellationToken)
    {
        bool success = await _productRepository.DeleteAsync(request.Id);

        if (!success)
        {
            return Result<Unit>.Failure($"Product with ID {request.Id} not found.");
        }


        return Result<Unit>.Success(Unit.Value);
    }
}