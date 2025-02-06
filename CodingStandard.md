# Coding Standards for `GitHub`

Start by reading the general coding standards for [`PSModule`](https://psmodule.io/docs) which is the basis for all modules in the framework.
Additions or adjustments to those defaults are covered in this document to ensure that the modules drive consistancy for all developers.

## General Coding Standards

1. **PowerShell Keywords**
   - All PowerShell keywords (e.g. `if`, `return`, `throw`, `function`, `param`) **must** be in lowercase.

2. **Brace Style**
   - Use **One True Bracing Style (OTBS)**.
   - Opening brace on the same line as the statement; closing brace on its own line.

3. **Coverage**
   - We do **not** need 100% coverage of the GitHub API.
   - Maintain a separate file listing the endpoints you intentionally **do not** cover, so the coverage report can mark them accordingly (e.g., ⚠️).

4. **Convert Filter Types**
   - Wherever filters are used, ensure they are implemented as standard PowerShell functions with `begin`, `process`, and `end` blocks.

---

## Functions

- **Grouping**
  - Group functions by the *object type* they handle, using folders named for that object type (e.g. “Repository”), **not** by the API endpoint URL.

- **Naming**
  - Public function name format: **`Verb-GitHubNoun`**.
  - Private function name format: **`Verb-GitHubNoun`** (same style but no aliases).
  - **`Get-`** functions must **not** include `[CmdletBinding(SupportsShouldProcess)]`. You only use `SupportsShouldProcess` on commands that change or remove data (`Set-`, `Remove-`, `Add-`, etc.).

- **Default Parameter Sets**
  - Do **not** declare `DefaultParameterSetName = '__AllParameterSets'`.
  - Only specify a `DefaultParameterSetName` if it is actually different from the first parameter set.

- **Public vs. Private**
  1. **Public Functions**
     - Support pipeline input if appropriate.
     - Should begin by calling `Resolve-GitHubContext` to handle the `Context` parameter, which can be either a string or a `GitHubContext` object.
     - Use parameter sets (with `begin`, `process`, `end`) if you have multiple ways to call the same logical operation.
     - If choosing among multiple underlying private functions, use a `switch` statement in the `process` block keyed on the parameter set name.
     - If a parameter like `$Repository` is missing, you can default to `$Context.Repo`. If no value is found, **throw** an error.
  2. **Private Functions**
     - **No pipeline input**.
     - No aliases on either the function or its parameters.
     - **`Context` is mandatory** (type `GitHubContext`), since public functions should already have resolved it.
     - **`Owner`, `Organization`, `ID`, `Repository`** are also mandatory if required by the endpoint.
     - Must not contain logic to default parameters from `Context`; that is resolved in public functions.

---

## Documentation for Functions

All function documentation follows standard PowerShell help conventions, with some notes:

1. **.SYNOPSIS**, **.DESCRIPTION**, **.EXAMPLES**
   - Examples in your code should include fencing (e.g., triple backticks) because the PSModule framework removes default fences.

2. **.PARAMETER**
   - Do **not** store parameter documentation in a comment block separate from the parameter. Instead, use inline parameter documentation via the `[Parameter()]` attribute and descriptions in triple-slash (`///`) comments above each parameter.

3. **.NOTES**
   - Include a link to the official documentation (if any) that the function is based on, so it’s discoverable via online help.

4. **.LINK**
   - First link should be the function’s own local documentation (generated for the PowerShell module).
   - Additional links can point to official GitHub or API documentation.

---

## Parameter Guidelines

1. **Always Declare [Parameter()]**
   - Every parameter must explicitly have a `[Parameter()]` attribute, even if empty.
   - Place these attributes in a consistent order (see **Parameter Attributes Order** below).

2. **Parameter Types**
   - Always specify a type, e.g. `[string] $Owner` (rather than `$Owner` alone).

3. **Parameter Naming**
   - Use **PascalCase** for parameters.
   - Convert snake_case from the API docs to **PascalCase** in the function.
   - **`ID`** should be the short name. If needed, add an alias for a long form (e.g., `[Alias('SomeLongName')]`) or for a different style (`'id'`, `'Id'`), depending on user expectations.
   - If the function name implies the object (e.g., `Get-GitHubRepository`), do **not** name the parameter `RepositoryId`. Just `ID` (or `Name`, etc.) suffices. Keep it object-oriented rather than repeating the context.
   - `Owner` should always have the aliases: `Organization` and `User`.
   - `Username` can have the alias `Login` if relevant for a particular API.
   - Use `Repository` (not `Repo`). If you need an alias for backward compatibility, add `[Alias('Repo')]`.

4. **Parameter Attribute Order**
   1. `[Parameter()]`
   2. `[ValidateNotNullOrEmpty()]` or other validation attributes
   3. `[Alias()]` if any
   4. Then the parameter definition itself: `[string] $ParamName`

5. **Parameter Defaulting**
   - For **public** functions, if the user hasn’t provided a parameter (like `$Repository`), default it from the context:
     ```powershell
     if (-not $Repository) {
         $Repository = $Context.Repo
     }
     if (-not $Repository) {
         throw "Repository not specified and not found in the context."
     }
     ```
   - For **private** functions, the calling function should already have done this. Private functions assume mandatory parameters.

6. **Remove `[org]` Alias**
   - Do not use `[Alias('org')]` on the `$Organization` parameter. Use `[Alias('User','Organization')]` on `$Owner` instead.

---

## Function Content & Flow

1. **Structure**
   - Always use `begin`, `process`, and `end` blocks.
   - **`begin`**: Validate parameters, call `Assert-GitHubContext` if needed, set up any local state.
     - Add a comment stating which permissions are required for the API call.
   - **`process`**: Main logic, including pipeline handling if public.
   - **`end`**: Cleanup if necessary.

2. **ShouldProcess**
   - Only use `[CmdletBinding(SupportsShouldProcess)]` for commands that create, update, or remove data. **Do not** apply it to `Get-` commands.

3. **API Method Naming**
   - Use PascalCase for the method in your splat (e.g., `Post`, `Delete`, `Put`, `Get`).
   - The `Method` property in your hashtable to `Invoke-GitHubAPI` (or other REST calls) should reflect that standard.

4. **Splatting**
   - Always splat the API call. The standard order in the splat is:
     1. `Method`
     2. `APIEndpoint` (or `Endpoint`, with `APIEndpoint` as an alias if necessary)
     3. `Body`
     4. `Context`
   - Body is always a hashtable containing the payload for `POST`, `PATCH`, or `PUT` calls.

5. **Removing String Checks**
   - Do **not** use `if ([string]::IsNullOrEmpty($Param))`. Instead, check `-not $Param` or rely on `[ValidateNotNullOrEmpty()]`.

6. **Pipeline Output**
   - After calling `Invoke-GitHubAPI @inputObject`, you can **either**:
     - `ForEach-Object { Write-Output $_.Response }`
     - or `Select-Object -ExpandProperty Response`
   - Choose which pattern best fits your scenario, but be consistent within a function.

---

## Classes

1. **One Class per Resource**
   - Each distinct resource type gets its own `.ps1` or `.psm1` with a single class definition.

2. **Property and Method Naming**
   - Use PascalCase for all public properties and methods.

3. **Return Types / Interfaces**
   - Each class that you return should have a consistent interface.
   - Remove any properties that are purely “API wrapper” fields (e.g., raw HTTP artifacts that aren’t relevant to the user).

---

## Additional Notes

1. **Endpoint Coverage File**
   - Maintain a list of endpoints you’re deliberately **not** implementing, so that your coverage reporting can include a ⚠️ for them.

2. **Parameter Name Design**
   - Use object-oriented naming that reflects the entity. For example, if the function is `Remove-GitHubRepository`, simply use `-ID` (or `-Name`) rather than `-RepositoryID`.

3. **Aliases**
   - Private functions have **no** aliases (function-level or parameter-level).
   - Public functions can add aliases where it makes sense (`Owner` has `-User`/`-Organization`, `Repository` might have `-Repo` alias if needed, `Username` might have `-Login`).

4. **Mandatory Context for Private**
   - Private functions must always expect a resolved `[GitHubContext] $Context`. Public functions handle any string-based or null context resolution logic.

5. **We Do Not Have to Cover Every Possible API**
   - Some endpoints (e.g., “hovercards” or other rarely used features) can be excluded.

---

That’s it. This spec captures all the bullet points and original guidelines in one place. Use it as the authoritative reference for coding style, function naming, parameter declarations, and general best practices in your module.
