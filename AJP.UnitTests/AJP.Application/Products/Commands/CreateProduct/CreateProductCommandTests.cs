using System;
using System.Threading;
using System.Threading.Tasks;
using AJP.Application.Common.Interfaces;
using AJP.Application.Products.Commands.CreateProduct;
using AJP.Domain.Entities;
using FluentValidation.TestHelper;
using Moq;

namespace AJP.UnitTests.AJP.Application.Products.Commands.CreateProduct;

public class CreateProductCommandTests
{
    private readonly Mock<IProductRepository> _mockProductRepository;
    private readonly CreateProductCommandHandler _handler;
    private readonly CreateProductCommandValidator _validator;

    public CreateProductCommandTests()
    {
        _mockProductRepository = new Mock<IProductRepository>();
        _handler = new CreateProductCommandHandler(_mockProductRepository.Object);
        _validator = new CreateProductCommandValidator();
    }

    [Fact]
    public async Task Handle_ValidProduct_ReturnsNewProductId()
    {
        // Arrange
        var command = new CreateProductCommand
        {
            Name = "Test Product",
            Description = "Test Description",
            Price = 19.99m
        };

        var expectedId = 1;
        _mockProductRepository.Setup(r => r.CreateAsync(It.IsAny<Product>()))
            .ReturnsAsync(expectedId);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.Equal(expectedId, result);
        _mockProductRepository.Verify(
            r => r.CreateAsync(
                It.Is<Product>(p =>
                    p.Name == command.Name &&
                    p.Description == command.Description &&
                    p.Price == command.Price)),
            Times.Once);
    }

    [Fact]
    public void Validate_EmptyName_ShouldHaveValidationError()
    {
        // Arrange
        var command = new CreateProductCommand
        {
            Name = string.Empty,
            Description = "Test Description",
            Price = 19.99m
        };

        // Act
        TestValidationResult<CreateProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldHaveValidationErrorFor(p => p.Name)
            .WithErrorMessage("Name is required.");
    }

    [Fact]
    public void Validate_NameTooLong_ShouldHaveValidationError()
    {
        // Arrange
        var command = new CreateProductCommand
        {
            Name = new string('A', 101),
            Description = "Test Description",
            Price = 19.99m
        };

        // Act
        TestValidationResult<CreateProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldHaveValidationErrorFor(p => p.Name)
            .WithErrorMessage("Name must not exceed 100 characters.");
    }

    [Fact]
    public void Validate_ZeroPrice_ShouldHaveValidationError()
    {
        // Arrange
        var command = new CreateProductCommand
        {
            Name = "Test Product",
            Description = "Test Description",
            Price = 0
        };

        // Act
        TestValidationResult<CreateProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldHaveValidationErrorFor(p => p.Price)
            .WithErrorMessage("Price must be greater than 0.");
    }

    [Fact]
    public void Validate_NegativePrice_ShouldHaveValidationError()
    {
        // Arrange
        var command = new CreateProductCommand
        {
            Name = "Test Product",
            Description = "Test Description",
            Price = -10
        };

        // Act
        TestValidationResult<CreateProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldHaveValidationErrorFor(p => p.Price)
            .WithErrorMessage("Price must be greater than 0.");
    }

    [Fact]
    public void Validate_ValidCommand_ShouldNotHaveValidationError()
    {
        // Arrange
        var command = new CreateProductCommand
        {
            Name = "Test Product",
            Description = "Test Description",
            Price = 19.99m
        };

        // Act
        TestValidationResult<CreateProductCommand> result = _validator.TestValidate(command);

        // Assert
        result.ShouldNotHaveAnyValidationErrors();
    }
}
