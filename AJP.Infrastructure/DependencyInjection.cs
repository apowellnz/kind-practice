using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace AJP.Infrastructure;

/// <summary>
/// Extension methods for setting up infrastructure services in an <see cref="IServiceCollection"/>.
/// </summary>
public static class DependencyInjection
{
    /// <summary>
    /// Adds infrastructure services to the service collection.
    /// </summary>
    /// <param name="services">The service collection to add services to.</param>
    /// <param name="configuration">The configuration instance.</param>
    /// <returns>The modified service collection.</returns>
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        // Add infrastructure services here
        return services;
    }
}
