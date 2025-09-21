using System.Threading;
using System.Threading.Tasks;
using AJP.Application.Common.Interfaces;
using AJP.Application.Common.Models;
using AJP.Application.Products.Commands.DeleteProduct;
using FluentValidation.TestHelper;
using MediatR;
using Moq;

namespace AJP.UnitTests.AJP.Application.Products.Commands.DeleteProduct;

public class DeleteProductCommandTests
{
    private readonly Mock<IProductRepository> _mockProductRepository;
    private readonly DeleteProductCommandHandler _handler;
    private readonly DeleteProductCommandValidator _validator;

    public DeleteProductCommandTests()
    {
        _mockProductRepository = new Mock<IProductRepository>();
        _handler = new DeleteProductCommandHandler(_mockProductRepository.Object);
        _validator = new DeleteProductCommandValidator();
    }

    [Fact]
    public async Task Handle_ProductExists_ReturnsSuccessResult()
    {
        // Arrange
        var command = new DeleteProductCommand(1);
        _mockProductRepository.Setup(r => r.DeleteAsync(command.Id)).ReturnsAsync(true);

        // Act
        Result<Unit> result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.True(result.IsSuccess);
        Assert.Equal(Unit.Value, result.Value);
        _mockProductRepository.Verify(r => r.DeleteAsync(command.Id), Times.Once);
    }

    [Fact]
    public async Task Handle_ProductDoesNotExist_ReturnsFailureResult()
    {
        // Arrange
        var command = new DeleteProductCommand(999);
        _mockProductRepository.Setup(r => r.DeleteAsync(command.Id)).ReturnsAsync(false);

        // Act
        Result<Unit> result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal($"Product with ID {command.Id} not found.", result.Error);
        _mockProductRepository.Verify(r => r.DeleteAsync(command.Id), Times.Once);
    }

    [Fact]
    public void Validate_ZeroId_ShouldHaveValidationError()
    {
        // Arrange
        var command = new DeleteProductCommand(0);

        // Act
        TestValidationResult<DeleteProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldHaveValidationErrorFor(p => p.Id)
            .WithErrorMessage("Id must be greater than 0.");
    }

    [Fact]
    public void Validate_NegativeId_ShouldHaveValidationError()
    {
        // Arrange
        var command = new DeleteProductCommand(-1);

        // Act
        TestValidationResult<DeleteProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldHaveValidationErrorFor(p => p.Id)
            .WithErrorMessage("Id must be greater than 0.");
    }

    [Fact]
    public void Validate_ValidId_ShouldNotHaveValidationError()
    {
        // Arrange
        var command = new DeleteProductCommand(1);

        // Act
        TestValidationResult<DeleteProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldNotHaveAnyValidationErrors();
    }
}
