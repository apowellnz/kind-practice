namespace AJP.Application.Common.Models;

public record Result<T>(bool IsSuccess, T? Value, string Error)
{
    public static Result<T> Success(T value) => new (true, value, string.Empty);
    public static Result<T> Failure(string error) => new (false, default, error);
}
