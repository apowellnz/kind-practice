// <copyright file="Error.cshtml.cs" company="AJP">
// Copyright (c) AJP. All rights reserved.
// </copyright>

using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace AJP.Frontend.Pages;

/// <summary>
/// Error page model.
/// </summary>
[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
public class ErrorModel : PageModel
{
    /// <summary>
    /// Gets or sets the request identifier.
    /// </summary>
    public string RequestId { get; set; } = string.Empty;

    /// <summary>
    /// Gets a value indicating whether to show the request ID.
    /// </summary>
    public bool ShowRequestId => !string.IsNullOrEmpty(RequestId);

    /// <summary>
    /// Handles the GET request.
    /// </summary>
    public void OnGet()
    {
        RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier;
    }
}
