using System.Threading;
using System.Threading.Tasks;
using AJP.Application.Common.Interfaces;
using AJP.Application.Common.Models;
using AJP.Application.Products.Commands.UpdateProduct;
using AJP.Domain.Entities;
using FluentValidation.TestHelper;
using MediatR;
using Moq;

namespace AJP.UnitTests.AJP.Application.Products.Commands.UpdateProduct;

public class UpdateProductCommandTests
{
    private readonly Mock<IProductRepository> _mockProductRepository;
    private readonly UpdateProductCommandHandler _handler;
    private readonly UpdateProductCommandValidator _validator;

    public UpdateProductCommandTests()
    {
        _mockProductRepository = new Mock<IProductRepository>();
        _handler = new UpdateProductCommandHandler(_mockProductRepository.Object);
        _validator = new UpdateProductCommandValidator();
    }

    [Fact]
    public async Task Handle_ProductExists_ReturnsSuccessResult()
    {
        // Arrange
        var command = new UpdateProductCommand
        {
            Id = 1,
            Name = "Updated Product",
            Description = "Updated Description",
            Price = 29.99m
        };

        _mockProductRepository.Setup(r => r.UpdateAsync(It.IsAny<Product>())).ReturnsAsync(true);

        // Act
        Result<Unit> result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.True(result.IsSuccess);
        Assert.Equal(Unit.Value, result.Value);
        _mockProductRepository.Verify(
            r => r.UpdateAsync(
                It.Is<Product>(p =>
                    p.Id == command.Id &&
                    p.Name == command.Name &&
                    p.Description == command.Description &&
                    p.Price == command.Price)),
            Times.Once);
    }

    [Fact]
    public async Task Handle_ProductDoesNotExist_ReturnsFailureResult()
    {
        // Arrange
        var command = new UpdateProductCommand
        {
            Id = 999,
            Name = "Updated Product",
            Description = "Updated Description",
            Price = 29.99m
        };

        _mockProductRepository.Setup(r => r.UpdateAsync(It.IsAny<Product>())).ReturnsAsync(false);

        // Act
        Result<Unit> result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal($"Product with ID {command.Id} not found.", result.Error);
        _mockProductRepository.Verify(r => r.UpdateAsync(It.Is<Product>(p => p.Id == command.Id)), Times.Once);
    }

    [Fact]
    public void Validate_ZeroId_ShouldHaveValidationError()
    {
        // Arrange
        var command = new UpdateProductCommand
        {
            Id = 0,
            Name = "Test Product",
            Description = "Test Description",
            Price = 19.99m
        };

        // Act
        TestValidationResult<UpdateProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldHaveValidationErrorFor(p => p.Id)
            .WithErrorMessage("Id must be greater than 0.");
    }

    [Fact]
    public void Validate_EmptyName_ShouldHaveValidationError()
    {
        // Arrange
        var command = new UpdateProductCommand
        {
            Id = 1,
            Name = string.Empty,
            Description = "Test Description",
            Price = 19.99m
        };

        // Act
        TestValidationResult<UpdateProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldHaveValidationErrorFor(p => p.Name)
            .WithErrorMessage("Name is required.");
    }

    [Fact]
    public void Validate_NameTooLong_ShouldHaveValidationError()
    {
        // Arrange
        var command = new UpdateProductCommand
        {
            Id = 1,
            Name = new string('A', 101),
            Description = "Test Description",
            Price = 19.99m
        };

        // Act
        TestValidationResult<UpdateProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldHaveValidationErrorFor(p => p.Name)
            .WithErrorMessage("Name must not exceed 100 characters.");
    }

    [Fact]
    public void Validate_ZeroPrice_ShouldHaveValidationError()
    {
        // Arrange
        var command = new UpdateProductCommand
        {
            Id = 1,
            Name = "Test Product",
            Description = "Test Description",
            Price = 0
        };

        // Act
        TestValidationResult<UpdateProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldHaveValidationErrorFor(p => p.Price)
            .WithErrorMessage("Price must be greater than 0.");
    }

    [Fact]
    public void Validate_ValidCommand_ShouldNotHaveValidationError()
    {
        // Arrange
        var command = new UpdateProductCommand
        {
            Id = 1,
            Name = "Test Product",
            Description = "Test Description",
            Price = 19.99m
        };

        // Act
        TestValidationResult<UpdateProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldNotHaveAnyValidationErrors();
    }
}
