// This file is used by Code Analysis to maintain SuppressMessage
// attributes that are applied to this project.
// Project-level suppressions either have no target or are given
// a specific target and scoped to a namespace, type, member, etc.

using System.Diagnostics.CodeAnalysis;

[assembly: SuppressMessage("StyleCop.CSharp.SpacingRules", "SA1009:Closing parenthesis should not be followed by a space", Justification = "Conflicts with other StyleCop rules", Scope = "module")]
[assembly: SuppressMessage("StyleCop.CSharp.SpacingRules", "SA1028:Code should not contain trailing whitespace", Justification = "Automatically inserted by many editors", Scope = "module")]
[assembly: SuppressMessage("StyleCop.CSharp.NamingRules", "SA1313:Parameter names should begin with lower-case letter", Justification = "Record primary constructors use PascalCase by convention", Scope = "module")]
[assembly: SuppressMessage("StyleCop.CSharp.SpacingRules", "SA1024:Colon should be preceded by a space", Justification = "Conflicts with other StyleCop rules", Scope = "module")]
[assembly: SuppressMessage("Minor Code Smell", "S2094:Classes should not be empty", Justification = "MediatR requires empty classes/records for marker requests", Scope = "module")]
[assembly: SuppressMessage("StyleCop.CSharp.SpacingRules", "SA1512:Single-line comments should not be followed by blank line", Justification = "StyleCop formatting preferences", Scope = "module")]
[assembly: SuppressMessage("StyleCop.CSharp.SpacingRules", "SA1513:Closing brace should be followed by blank line", Justification = "StyleCop formatting preferences", Scope = "module")]
