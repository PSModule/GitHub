# Guidelines

Writing down guidelines so that it can be the basis for pester tests.

## Functions

- Group functions by the object type they are working with in a folder based on the name of the object, NOT based on the API.
- DefaultParameterSetName must never be declared unless its different the default parameter set.

### Name

- Verb-GitHubNoun - based on what object type they are working with. Let parameters dictate the scope of the function.

#### Name - Public functions

#### Name - Private functions

- No aliases

### Documentation

#### .SYNOPSIS

#### .DESCRIPTION

#### .EXAMPLES

- PSModule framework removes the default fencing. So, we need to add the fencing back in the examples where we see fit.

#### .PARAMETERS

- Parameter docs do not go in the comment block. They are in the `param` block above each parameter.
  Principle: Keep documentation close to the code it documents.

#### .NOTES

- Have a link to the documentation with the display name of the official documentation. This is so that when user search on the online
function documentation they can search based on the official documentation.

#### .LINK

- First link is to the function documentation that is generated for the PowerShell module.
- Other links can be to the official documentation.

### Parameters

- Parameters use the PascalCase version of the parameter name in the official documentation.

#### Parameters - public functions

- `Context` parameter supports `string` and `GitHubContext`. -> This is why we have `Resolve-GitHubContext` in the public functions.
- Evaluation of default values for other scoping parameters happen in `process` block.
- `Owner` always have `User` and `Organization` as aliases
- `Repository` is always spelled out.
- `ID` when needed, should be the short form, but have the long form as an alias supporting both lower_snake_case and PascalCase.

#### Parameters - private functions

- No aliases
- `Context` parameter is `GitHubContext`. Calling function should have resolved the context to a `GitHubContext` object already.

### Content

- Use begin, process, end and optionally clean blocks.
- begin block is for parameter validation and setup.
- process block is for the main logic. This should also have a foreach loop for pipelining.
- All context defaults must be evaluated in the process block.
- One API call = one function
- API parameters are always splatted
  - The name of the splat is `$inputObject`
  - The order of the splat is:
    - `Method`
    - `APIEndpoint`
    - `Body`
    - `Context`
- API Body is always a hashtable

- If function calls `Invoke-GitHubAPI`, `Invoke-RestMethod` or `Invoke-WebRequest` that requires a `Context` parameter:
  - Function must also have `Assert-GitHubContext` in begin block.
    - Add a comment below `Assert-GitHubContext` stating the permissions needed for the API call.

### Content - Public

- If Public function
  - Resolve-GitHubContext

- To select underlying private functions use parameter sets, in a swticth statement.
  - Use the `default` block to cover the default parameter set `__AllParameterSets`.

### Content - Private

- Pipelining is not supported

## Classes

- One class pr type of resource
- Properties are PascalCased (as expected by PowerShell users)

```pwsh
if ([string]::IsNullOrEmpty($Enterprise)) {
    $Enterprise = $Context.Enterprise
}
Write-Debug "Enterprise: [$Enterprise]"

if ([string]::IsNullOrEmpty($Organization)) {
    $Organization = $Context.Organization
}
Write-Debug "Organization: [$Organization]"

if ([string]::IsNullOrEmpty($Owner)) {
    $Owner = $Context.Owner
}
Write-Debug "Owner: [$Owner]"

if ([string]::IsNullOrEmpty($Repo)) {
    $Repo = $Context.Repo
}
Write-Debug "Repo: [$Repo]"

# What about "Name", "Login", "Username"
```


## TO DO

In private, make Context Mandatory

if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
Write-Debug "Repo: [$Repo]"
if (-not $Repo) { throw }

Remove [org] alias on $organization parameter

Rename $Repo to $Repository

Add Alias Organization and User for $Owner prarm
Aliases, one pr line or one pr definition?

Document: API Method is written in Sentencase/PascalCase, Post, Delete, Put, Get, etc.

SupportsShouldProcess must not be on Get- functions

Context Enterprise, Owner, Organization, ID, Repo Are mandatory in private functions


Parameters always have a [Parameter()] attribute
Parameters always define type, then a space to the value [string] $String
ID should be the main parameter name
Parameters, snake_case -> PascalCase

Dont use DefaultParameterSet = '__AllParameterSets'

Class every return to have an agreed interface
Remove API spefic properties

Username alias is login

All powershell keywords = lowercase

Brace style: One True Bracing Style (OTBS)
https://en.wikipedia.org/wiki/Indentation_style

Private functions do not take pipeline params
Private functions have no aliases, on functions or params

We do really not have to have 100% API coverage... like Hovercards.. ?
convert all filter types to function type (we have begin, process, end)

Parameter attribute order:
1. Parameter()]
Function attribute order:
y. [CmdletBinding()]
z. param()


Output to pipeline, select or foreach?
Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }

Invoke-GitHubAPI @inputObject | Select-Object -ExpandProperty Response


Rename APIEndpoint to Endpoint (maybe keep APIEndpoint as alias)


Remove if([string]IsNullOrEmpty())


Add a file where we store endponits we do not wish to cover. Update the coverage report with ⚠️

Parameter name design: Assume there is an object that is processed. Not RepositoryID for a function that has repository in it. The value/name at hand is related to the object being processed. Object oriented naming.
