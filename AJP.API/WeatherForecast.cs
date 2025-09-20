namespace AJP.API;

/// <summary>
/// Weather forecast record.
/// </summary>
/// <param name="date">The date of the forecast.</param>
/// <param name="temperatureC">The temperature in Celsius.</param>
/// <param name="summary">A summary of the weather conditions.</param>
public record WeatherForecast(DateOnly date, int temperatureC, string? summary)
{
    /// <summary>
    /// Gets the temperature in Fahrenheit.
    /// </summary>
    public int TemperatureF => 32 + (int)(temperatureC / 0.5556);
}
