// <copyright file="SampleDataController.cs" company="AJP">
// Copyright (c) AJP. All rights reserved.
// </copyright>

using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc;

namespace AJP.Frontend.Controllers;

/// <summary>
/// Sample data controller for weather forecasts.
/// </summary>
[Route("api/[controller]")]
public class SampleDataController : Controller
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching",
    };

    /// <summary>
    /// Gets weather forecasts.
    /// </summary>
    /// <returns>A collection of weather forecasts.</returns>
    [HttpGet("[action]")]
    public IEnumerable<WeatherForecast> WeatherForecasts()
    {
        var rng = new Random();
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            DateFormatted = DateTime.Now.AddDays(index).ToString("d"),
            TemperatureC = rng.Next(-20, 55),
            Summary = Summaries[rng.Next(Summaries.Length)],
        });
    }

    /// <summary>
    /// Weather forecast data model.
    /// </summary>
    public class WeatherForecast
    {
        /// <summary>
        /// Gets or sets the formatted date.
        /// </summary>
        public string DateFormatted { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the temperature in Celsius.
        /// </summary>
        public int TemperatureC { get; set; }

        /// <summary>
        /// Gets or sets the weather summary.
        /// </summary>
        public string Summary { get; set; } = string.Empty;

        /// <summary>
        /// Gets the temperature in Fahrenheit.
        /// </summary>
        public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
    }
}
