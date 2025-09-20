// <copyright file="Program.cs" company="AJP">
// Copyright (c) AJP. All rights reserved.
// </copyright>

using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;

namespace AJP.Frontend;

/// <summary>
/// The entry point class for the application.
/// </summary>
public static class Program
{
    /// <summary>
    /// The entry point method for the application.
    /// </summary>
    /// <param name="args">Command line arguments.</param>
    public static void Main(string[] args)
    {
        CreateHostBuilder(args).Build().Run();
    }

    /// <summary>
    /// Creates the host builder.
    /// </summary>
    /// <param name="args">Command line arguments.</param>
    /// <returns>The host builder.</returns>
    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>();
            });
}
