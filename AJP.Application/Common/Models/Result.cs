namespace AJP.Application.Common.Models;

/// <summary>
/// A generic wrapper for returning results from methods.
/// </summary>
/// <typeparam name="T">The type of the result value.</typeparam>
public class Result<T>
{
    private Result(bool isSuccess, T? value, string? error)
    {
        IsSuccess = isSuccess;
        Value = value;
        Error = error;
    }

    /// <summary>
    /// Gets a value indicating whether the result is successful.
    /// </summary>
    public bool IsSuccess { get; }

    /// <summary>
    /// Gets the result value. Will be default(T) if IsSuccess is false.
    /// </summary>
    public T? Value { get; }

    /// <summary>
    /// Gets the error message. Will be null if IsSuccess is true.
    /// </summary>
    public string? Error { get; }

    /// <summary>
    /// Creates a successful result with the specified value.
    /// </summary>
    /// <param name="value">The result value.</param>
    /// <returns>A successful result containing the value.</returns>
    public static Result<T> Success(T value) => new(true, value, null);

    /// <summary>
    /// Creates a failure result with the specified error message.
    /// </summary>
    /// <param name="error">The error message.</param>
    /// <returns>A failure result containing the error message.</returns>
    public static Result<T> Failure(string error) => new(false, default, error);
}
