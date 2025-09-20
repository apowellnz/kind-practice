using System.ComponentModel.DataAnnotations;
using AJP.Application.Common.Models;
using AJP.Application.Products.Commands.CreateProduct;
using AJP.Application.Products.Commands.DeleteProduct;
using AJP.Application.Products.Commands.UpdateProduct;
using AJP.Application.Products.Queries.GetAllProducts;
using AJP.Application.Products.Queries.GetProductById;
using AJP.Domain.Entities;
using MediatR;

namespace AJP.API;

/// <summary>
/// Application entry point.
/// </summary>
public static class Program
{
    /// <summary>
    /// Main entry point.
    /// </summary>
    /// <param name="args">Command line arguments.</param>
    public static void Main(string[] args)
    {
        WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen();
        // builder.Services.AddInfrastructure(builder.Configuration);
        // builder.Services.AddPersistence(builder.Configuration);

        WebApplication app = builder.Build();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        app.UseHttpsRedirection();

        // Group endpoints by feature
        RouteGroupBuilder productsGroup = app.MapGroup("/products")
            .WithTags("Products")
            .WithOpenApi();

        productsGroup.MapGet("/", async (IMediator mediator) =>
            {
                IEnumerable<Product> products = await mediator.Send(new GetAllProductsQuery());
                return Results.Ok(products);
            })
            .WithName("GetAllProducts");

        productsGroup.MapGet("/{id}", async (int id, IMediator mediator) =>
            {
                Result<Product> result = await mediator.Send(new GetProductByIdQuery(id));
                return result.IsSuccess
                    ? Results.Ok(result.Value)
                    : Results.NotFound(result.Error);
            })
            .WithName("GetProductById");

        productsGroup.MapPost("/", async (CreateProductCommand command, IMediator mediator) =>
            {
                try
                {
                    int id = await mediator.Send(command);
                    return Results.Created($"/products/{id}", id);
                }
                catch (ValidationException ex)
                {
                    return Results.BadRequest(ex.InnerException?.Message ?? ex.Message);
                }
            })
            .WithName("CreateProduct");

        productsGroup.MapPut("/{id}", async (int id, UpdateProductCommand command, IMediator mediator) =>
            {
                if (id != command.Id)
                {
                    return Results.BadRequest("ID in URL does not match ID in request body");
                }

                try
                {
                    var result = await mediator.Send(command);

                    if (!result.IsSuccess)
                    {
                        return Results.NotFound(result.Error);
                    }

                    return Results.NoContent();
                }
                catch (ValidationException ex)
                {
                    return Results.BadRequest(ex.InnerException?.Message ?? ex.Message);
                }
            })
            .WithName("UpdateProduct");

        productsGroup.MapDelete("/{id}", async (int id, IMediator mediator) =>
            {
                var command = new DeleteProductCommand(id);
                var result = await mediator.Send(command);

                if (!result.IsSuccess)
                {
                    return Results.NotFound(result.Error);
                }


                return Results.NoContent();
            })
            .WithName("DeleteProduct");

        app.Run();
    }
}
