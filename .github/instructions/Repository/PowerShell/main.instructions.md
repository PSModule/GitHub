---
description: "How to write PowerShell code in this specific project"
applyTo: "**/*.ps1, **/*.psm1, **/*.psd1"
---

# PowerShell Code Patterns for GitHub Module

This document provides concrete examples of how to write PowerShell code in the GitHub PowerShell module. These examples are extracted from the actual codebase and demonstrate the project-specific implementation patterns.


## Context Resolution Pattern

### Implementation in Resolve-GitHubContext

The context resolution pattern is central to the module's authentication system. Here's how it's implemented:

```powershell
filter Resolve-GitHubContext {
    [OutputType([GitHubContext])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [object] $Context,

        [Parameter()]
        [bool] $Anonymous
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Initialize-GitHubConfig
    }

    process {
        Write-Verbose "Context:"
        $Context | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
        Write-Verbose "Anonymous: [$Anonymous]"

        if ($Anonymous -or $Context -eq 'Anonymous') {
            Write-Verbose 'Returning Anonymous context.'
            return [GitHubContext]::new(
                [pscustomobject]@{
                    Name     = 'Anonymous'
                    AuthType = 'Anonymous'
                }
            )
        }

        if ($Context -is [string]) {
            $contextName = $Context
            Write-Verbose "Getting context: [$contextName]"
            $Context = Get-GitHubContext -Context $contextName
        }

        if ($null -eq $Context) {
            Write-Verbose 'Context is null, returning default context.'
            $Context = Get-GitHubContext
        }

        switch ($Context.TokenType) {
            'ghu' {
                Write-Verbose 'Update GitHub User Access Token.'
                $Context = Update-GitHubUserAccessToken -Context $Context -PassThru
            }
            'JWT' {
                Write-Verbose 'Update GitHub App JWT Token.'
                $Context = Update-GitHubAppJWT -Context $Context -PassThru
            }
        }

        $Context
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
```

**Key Pattern Elements:**

- **`filter` keyword**: Used instead of `function` for streaming pipeline behavior
- **`[AllowNull()]` attribute**: Permits null values for context parameter (important for defaulting)
- **String to object resolution**: Handles both string context names and GitHubContext objects
- **Token refresh logic**: Automatically updates expiring tokens based on TokenType
- **Null handling**: Returns default context when no context provided

**Usage in Public Functions:**

```powershell
begin {
    $stackPath = Get-PSCallStackPath
    Write-Debug "[$stackPath] - Start"

    # Resolve context - converts string names or null to GitHubContext objects
    $Context = Resolve-GitHubContext -Context $Context

    # Validate authentication type for this operation
    Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
}
```

---

## API Call Pattern

### Implementation in Invoke-GitHubAPI

The `Invoke-GitHubAPI` function is the foundation for all REST API calls. Here's the core pattern:

```powershell
function Invoke-GitHubAPI {
    [CmdletBinding(DefaultParameterSetName = 'ApiEndpoint')]
    param(
        [Parameter()]
        [ValidateSet('GET', 'POST', 'PUT', 'DELETE', 'PATCH')]
        $Method = 'GET',

        [Parameter(
            Mandatory,
            ParameterSetName = 'ApiEndpoint'
        )]
        [string] $ApiEndpoint,

        [Parameter()]
        [Alias('Query')]
        [object] $Body,

        [Parameter()]
        [string] $Accept = 'application/vnd.github+json; charset=utf-8',

        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $debug = $DebugPreference -eq 'Continue'

        # Resolve context with anonymous support
        $Context = Resolve-GitHubContext -Context $Context -Anonymous $Anonymous

        if ($debug) {
            Write-Debug 'Invoking GitHub API...'
            Write-Debug 'Parent function parameters:'
            Get-FunctionParameter -Scope 1 | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
            Write-Debug 'Parameters:'
            Get-FunctionParameter | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        }
    }

    process {
        # Resolve all settings from context
        $Token = $Context.Token
        $HttpVersion = Resolve-GitHubContextSetting -Name 'HttpVersion' -Value $HttpVersion -Context $Context
        $ApiBaseUri = Resolve-GitHubContextSetting -Name 'ApiBaseUri' -Value $ApiBaseUri -Context $Context
        $ApiVersion = Resolve-GitHubContextSetting -Name 'ApiVersion' -Value $ApiVersion -Context $Context
        $RetryCount = Resolve-GitHubContextSetting -Name 'RetryCount' -Value $RetryCount -Context $Context
        $RetryInterval = Resolve-GitHubContextSetting -Name 'RetryInterval' -Value $RetryInterval -Context $Context

        # Build headers
        $headers = @{
            Accept                 = $Accept
            'X-GitHub-Api-Version' = $ApiVersion
            'User-Agent'           = $script:UserAgent
        }
        $headers | Remove-HashtableEntry -NullOrEmptyValues

        # Build URI
        if (-not $Uri) {
            $Uri = New-Uri -BaseUri $ApiBaseUri -Path $ApiEndpoint -AsString
            $Uri = $Uri -replace '//$', '/'
        }

        # Build API call splat
        $APICall = @{
            Uri               = $Uri
            Method            = [string]$Method
            Headers           = $Headers
            ContentType       = $ContentType
            InFile            = $UploadFilePath
            HttpVersion       = [string]$HttpVersion
            MaximumRetryCount = $RetryCount
            RetryIntervalSec  = $RetryInterval
        }
        $APICall | Remove-HashtableEntry -NullOrEmptyValues

        # Add authentication for non-anonymous requests
        if (-not $Anonymous -and $Context.Name -ne 'Anonymous') {
            $APICall['Authentication'] = 'Bearer'
            $APICall['Token'] = $Token
        }

        # Handle GET parameters as query string
        if ($Method -eq 'GET') {
            if (-not $Body) {
                $Body = @{}
            }
            $Body['per_page'] = Resolve-GitHubContextSetting -Name 'PerPage' -Value $PerPage -Context $Context
            $APICall.Uri = New-Uri -BaseUri $Uri -Query $Body -AsString
        }
        # Handle POST with file upload
        elseif (($Method -eq 'POST') -and -not [string]::IsNullOrEmpty($UploadFilePath)) {
            $APICall.Uri = New-Uri -BaseUri $Uri -Query $Body -AsString
        }
        # Handle body for other methods
        elseif ($Body) {
            if ($Body -is [hashtable]) {
                $APICall.Body = $Body | ConvertTo-Json -Depth 100
            } else {
                $APICall.Body = $Body
            }
        }

        try {
            do {
                $response = Invoke-WebRequest @APICall -ProgressAction 'SilentlyContinue' -Debug:$false -Verbose:$false

                # Process response headers
                $headers = @{}
                foreach ($item in $response.Headers.GetEnumerator()) {
                    $headers[$item.Key] = ($item.Value).Trim() -join ', '
                }

                # Parse content based on Content-Type
                switch -Regex ($headers.'Content-Type') {
                    'application/.*json' {
                        $results = $response.Content | ConvertFrom-Json
                    }
                    'application/octocat-stream' {
                        [byte[]]$byteArray = $response.Content
                        $results = [System.Text.Encoding]::UTF8.GetString($byteArray)
                    }
                    default {
                        $results = $response.Content
                    }
                }

                # Return structured response
                [pscustomobject]@{
                    Request           = $APICall
                    Response          = $results
                    Headers           = $headers
                    StatusCode        = $response.StatusCode
                    StatusDescription = $response.StatusDescription
                }

                # Follow pagination
                $APICall['Uri'] = $response.RelationLink.next
            } while ($APICall['Uri'])
        } catch {
            # Detailed error handling (see Error Handling section)
            $errordetails = $_.ErrorDetails | ConvertFrom-Json -AsHashtable
            $errorResult = [pscustomobject]@{
                Message     = $errordetails.message
                Resource    = $errordetails.errors.resource
                Code        = $errordetails.errors.code
                Details     = $errordetails.errors.message
                Information = $errordetails.documentation_url
                Status      = $_.Exception.Message
                StatusCode  = $errordetails.status
                ErrorTime   = Get-Date -Format 's'
            }

            # Build comprehensive exception message
            $exception = @"
----------------------------------
Context:
$($Context | Format-List | Out-String)
----------------------------------
Request:
$([pscustomobject]$APICall | Select-Object -ExcludeProperty Body, Headers | Format-List | Out-String)
----------------------------------
Error:
$($errorResult | Format-List | Out-String)
----------------------------------
"@
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    [System.Exception]::new($exception),
                    'GitHubAPIError',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $errorResult
                )
            )
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
```

**Key Pattern Elements:**

- **Setting resolution**: Use `Resolve-GitHubContextSetting` to get values from context with parameter overrides
- **Header construction**: Build headers hashtable, then remove null/empty values
- **URI construction**: Use `New-Uri` helper for consistent URI building
- **Splat pattern**: Build `$APICall` hashtable, clean it, then splat to `Invoke-WebRequest`
- **Method-specific handling**: Different logic for GET (query string), POST with upload (query string), and other methods (JSON body)
- **Pagination**: Automatic do-while loop following `RelationLink.next`
- **Response processing**: Content-Type-aware deserialization
- **Structured output**: Always return `[pscustomobject]` with Request, Response, Headers, StatusCode, StatusDescription

---

## Public Function Structure

### Complete Example from Get-GitHubRepository

Here's the full pattern for a public function with multiple parameter sets:

```powershell
filter Get-GitHubRepository {
    <#
        .SYNOPSIS
        Get a repository or list of repositories

        .DESCRIPTION
        Gets a repository or list of repositories based on the provided parameters.

        .EXAMPLE
        Get-GitHubRepository -Owner 'octocat' -Name 'Hello-World'

        Gets the repository 'Hello-World' for the organization 'octocat'.

        .OUTPUTS
        GitHubRepository
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Parameters are used in different parameter sets')]
    param(
        # The account owner of the repository.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByName'
        )]
        [Parameter(ParameterSetName = 'List')]
        [Alias('Organization', 'Username')]
        [string] $Owner,

        # The name of the repository without the .git extension.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByName',
            ValueFromPipelineByPropertyName
        )]
        [Alias('Repository', 'Repo')]
        [string] $Name,

        # The unique identifier of the repository.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByID',
            ValueFromPipelineByPropertyName
        )]
        [Alias('RepositoryID', 'RepoID')]
        [int] $ID,

        # Properties to include in the returned object.
        [Parameter()]
        [string[]] $Property,

        # Additional properties to include in the returned object.
        [Parameter()]
        [string[]] $AdditionalProperty,

        # The context to run the command in.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"

        # Resolve and validate context
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        # Default Owner from context if not provided
        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
    }

    process {
        # Route to appropriate private function based on parameter set
        $params = @{
            Context = $Context
        }

        if ($Property) {
            $params['Property'] = $Property
        }

        if ($AdditionalProperty) {
            $params['AdditionalProperty'] = $AdditionalProperty
        }

        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                Write-Debug "Getting repository by name: [$Owner/$Name]"
                $params['Owner'] = $Owner
                $params['Name'] = $Name
                Get-GitHubRepositoryByName @params
            }
            'ByID' {
                Write-Debug "Getting repository by ID: [$ID]"
                $params['ID'] = $ID
                Get-GitHubRepositoryByID @params
            }
            'List' {
                Write-Debug "Listing repositories for owner: [$Owner]"
                $params['Owner'] = $Owner
                Get-GitHubRepositoryList @params
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
```

**Key Pattern Elements:**

- **`filter` keyword**: Enables streaming pipeline behavior
- **`[OutputType()]`**: Always declare output type for IntelliSense and documentation
- **`[CmdletBinding(DefaultParameterSetName = '...')]`**: Specify default parameter set
- **`[SuppressMessageAttribute]`**: Suppress false PSScriptAnalyzer warnings with justification
- **Standard aliases**: `Owner` aliased to `Organization`/`Username`, `Name` aliased to `Repository`/`Repo`
- **Context resolution in `begin` block**: Resolve and assert context once before processing pipeline
- **Parameter defaulting from context**: `if ([string]::IsNullOrEmpty($Owner)) { $Owner = $Context.Owner }`
- **Switch on parameter set**: Route to different private functions based on `$PSCmdlet.ParameterSetName`
- **Parameter splatting**: Build `$params` hashtable conditionally, then splat to private function

---

## Private Function Structure

### Complete Example from Get-GitHubRepositoryByName

Here's the full pattern for a private function:

```powershell
filter Get-GitHubRepositoryByName {
    <#
        .SYNOPSIS
        Get a repository

        .DESCRIPTION
        The `parent` and `source` objects are present when the repository is a fork.
        `parent` is the repository this repository was forked from, `source` is the ultimate source for the network.

        .EXAMPLE
        Get-GitHubRepositoryByName -Owner 'octocat' -Name 'Hello-World'

        Gets the repository 'Hello-World' for the organization 'octocat'.

        .OUTPUTS
        GitHubRepository
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Name,

        # Properties to include in the returned object.
        [Parameter()]
        [string[]] $Property = @(
            'ID',
            'NodeID'
            'Name',
            'Owner',
            'FullName',
            'Url',
            'Description',
            'CreatedAt',
            'UpdatedAt',
            'PushedAt',
            'ArchivedAt',
            'Homepage',
            'Size',
            'Language',
            'HasIssues',
            'HasProjects',
            'HasWiki',
            'HasDiscussions',
            'HasSponsorships',
            'IsArchived',
            'IsTemplate',
            'IsFork',
            'License',
            'AllowForking',
            'RequireWebCommitSignoff',
            'Topics',
            'Visibility',
            'OpenIssues',
            'OpenPullRequests',
            'Stargazers',
            'Watchers',
            'Forks',
            'DefaultBranch',
            'Permission',
            'AllowSquashMerge',
            'AllowMergeCommit',
            'AllowRebaseMerge',
            'AllowAutoMerge',
            'DeleteBranchOnMerge',
            'SuggestUpdateBranch',
            'SquashMergeCommitTitle',
            'SquashMergeCommitMessage',
            'MergeCommitTitle',
            'MergeCommitMessage',
            'TemplateRepository',
            'ForkRepository',
            'CustomProperties',
            'CloneUrl',
            'SshUrl',
            'GitUrl'
        ),

        # Additional properties to include in the returned object.
        [Parameter()]
        [string[]] $AdditionalProperty,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"

        # Assert context authentication type
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        # Build GraphQL field list from property names
        $graphParams = @{
            PropertyList         = $Property + $AdditionalProperty
            PropertyToGraphQLMap = [GitHubRepository]::PropertyToGraphQLMap
        }
        $graphQLFields = ConvertTo-GitHubGraphQLField @graphParams

        # Call GraphQL API
        $apiParams = @{
            Query     = @"
query(
    `$Owner: String!,
    `$Name: String!
) {
  repositoryOwner(
    login: `$Owner
  ) {
    repository(
        name: `$Name
    ) {
$graphQLFields
    }
  }
}
"@
            Variables = @{
                Owner = $Owner
                Name  = $Name
            }
            Context   = $Context
        }

        Invoke-GitHubGraphQLQuery @apiParams | ForEach-Object {
            [GitHubRepository]::new($_.repositoryOwner.repository)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
```

**Key Pattern Elements:**

- **`[Parameter(Mandatory)]` on Context**: Private functions always require context (no defaulting)
- **Default property list**: Comprehensive default array of properties to fetch
- **GraphQL field mapping**: Convert PowerShell property names to GraphQL fields using class mapping
- **Here-string for queries**: Use `@"..."@` for multi-line GraphQL queries
- **Escape dollar signs**: Use backtick before `$` in GraphQL variables: `` `$Owner ``
- **Type constructor**: Create typed object from API response: `[GitHubRepository]::new($_.repositoryOwner.repository)`
- **Pipeline support**: Use `ForEach-Object` to stream results through pipeline

---

## Parameter Splatting

### Cleaning Hashtables Before Splatting

This module uses the `Remove-HashtableEntry` helper to clean hashtables before splatting:

```powershell
# Build parameter hashtable conditionally
$params = @{
    Context = $Context
}

if ($Property) {
    $params['Property'] = $Property
}

if ($AdditionalProperty) {
    $params['AdditionalProperty'] = $AdditionalProperty
}

# No need to clean - only add properties that exist
Get-GitHubRepositoryByName @params
```

**Alternative pattern for API calls:**

```powershell
# Build API call hashtable with all possible parameters
$APICall = @{
    Uri               = $Uri
    Method            = [string]$Method
    Headers           = $Headers
    ContentType       = $ContentType
    InFile            = $UploadFilePath
    HttpVersion       = [string]$HttpVersion
    MaximumRetryCount = $RetryCount
    RetryIntervalSec  = $RetryInterval
}

# Remove null or empty values before splatting
$APICall | Remove-HashtableEntry -NullOrEmptyValues

Invoke-WebRequest @APICall
```

**Key Pattern Elements:**

- **Conditional addition**: Only add parameters to hashtable if they have values
- **Remove-HashtableEntry**: Use `-NullOrEmptyValues` switch to clean before splatting
- **Splat with `@`**: Use `@params` not `$params` when calling function

---

## Error Handling

### Comprehensive Error Handling from Invoke-GitHubAPI

```powershell
try {
    $response = Invoke-WebRequest @APICall -ProgressAction 'SilentlyContinue' -Debug:$false -Verbose:$false

    # Process successful response...

} catch {
    $failure = $_

    # Parse error details from API response
    $errordetails = $failure.ErrorDetails | ConvertFrom-Json -AsHashtable
    $errors = $errordetails.errors

    # Build structured error object
    $errorResult = [pscustomobject]@{
        Message     = $errordetails.message
        Resource    = $errors.resource
        Code        = $errors.code
        Details     = $errors.message
        Information = $errordetails.documentation_url
        Status      = $failure.Exception.Message
        StatusCode  = $errordetails.status
        ErrorTime   = Get-Date -Format 's'
    }

    # Build comprehensive exception message with context
    $exception = @"

----------------------------------
Context:
$($Context | Format-List | Out-String)
----------------------------------
Request:
$([pscustomobject]$APICall | Select-Object -ExcludeProperty Body, Headers | Format-List | Out-String)
----------------------------------
Request headers:
$([pscustomobject]$APICall.Headers | Format-List | Out-String)
----------------------------------
Request body:
$("$($APICall.Body | Out-String -Stream)".Split('\n') -split '\n')
----------------------------------
Response headers:
$($headers | Format-List | Out-String)
----------------------------------
Error:
$($errorResult | Format-List | Out-String)
----------------------------------

"@

    # Throw terminating error with all context
    $PSCmdlet.ThrowTerminatingError(
        [System.Management.Automation.ErrorRecord]::new(
            [System.Exception]::new($exception),
            'GitHubAPIError',
            [System.Management.Automation.ErrorCategory]::InvalidOperation,
            $errorResult
        )
    )
}
```

**Key Pattern Elements:**

- **Parse ErrorDetails**: GitHub API returns structured error in `$_.ErrorDetails` as JSON
- **Structured error object**: Create `[pscustomobject]` with all error properties
- **Context in error message**: Include context, request, headers, body, and response in exception
- **Here-string for formatting**: Use `@"..."@` for multi-line error message with embedded expressions
- **ThrowTerminatingError**: Use `$PSCmdlet.ThrowTerminatingError()` not `throw` for proper error records
- **Include TargetObject**: Pass `$errorResult` as TargetObject for error record

---

## GraphQL Query Pattern

### Building and Executing GraphQL Queries

```powershell
# Build field list from properties
$graphParams = @{
    PropertyList         = $Property + $AdditionalProperty
    PropertyToGraphQLMap = [GitHubRepository]::PropertyToGraphQLMap
}
$graphQLFields = ConvertTo-GitHubGraphQLField @graphParams

# Build GraphQL query with here-string
$apiParams = @{
    Query     = @"
query(
    `$Owner: String!,
    `$Name: String!
) {
  repositoryOwner(
    login: `$Owner
  ) {
    repository(
        name: `$Name
    ) {
$graphQLFields
    }
  }
}
"@
    Variables = @{
        Owner = $Owner
        Name  = $Name
    }
    Context   = $Context
}

# Execute query and create typed objects
Invoke-GitHubGraphQLQuery @apiParams | ForEach-Object {
    [GitHubRepository]::new($_.repositoryOwner.repository)
}
```

**Key Pattern Elements:**

- **Property mapping**: Use class's `PropertyToGraphQLMap` to convert PowerShell names to GraphQL fields
- **Escape variables**: Use backtick before `$` in GraphQL query: `` `$Owner ``
- **Variables hashtable**: Separate query from variables for security and reusability
- **Indented field list**: Insert `$graphQLFields` with proper indentation in query
- **Type constructor**: Create typed object from nested response: `[GitHubRepository]::new($_.repositoryOwner.repository)`

---

## Filter Usage

### When to Use `filter` Instead of `function`

This module prefers `filter` for **all** public and private functions to enable streaming pipeline behavior:

```powershell
# ✅ CORRECT: Use filter for pipeline support
filter Get-GitHubRepository {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Name,

        [Parameter()]
        [object] $Context
    )

    begin {
        # Resolve context once
        $Context = Resolve-GitHubContext -Context $Context
    }

    process {
        # This runs for each pipeline object
        Get-GitHubRepositoryByName -Owner $Owner -Name $Name -Context $Context
    }

    end {
        # Cleanup if needed
    }
}

# ❌ WRONG: Don't use function unless you have a specific reason
function Get-GitHubRepository {
    # This doesn't support streaming pipeline
}
```

**Key Pattern Elements:**

- **`filter` = `function` + automatic `process` block**: Filter wraps entire body in `process {}`
- **Explicit blocks with filter**: Can still use `begin`/`process`/`end` with filter
- **Context in `begin`**: Resolve context in `begin` block to avoid repeating for each pipeline object
- **Stream results**: Don't collect in array - output directly to pipeline

---

## Pipeline Support

### ValueFromPipelineByPropertyName Pattern

```powershell
filter Get-GitHubRepository {
    param(
        # Bind from Owner property of pipeline object
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByName'
        )]
        [Alias('Organization', 'Username')]
        [string] $Owner,

        # Bind from Name/Repository/Repo property of pipeline object
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByName',
            ValueFromPipelineByPropertyName
        )]
        [Alias('Repository', 'Repo')]
        [string] $Name,

        # Context does NOT come from pipeline
        [Parameter()]
        [object] $Context
    )

    begin {
        # Resolve context once before processing pipeline
        $Context = Resolve-GitHubContext -Context $Context
    }

    process {
        # This runs for each pipeline object
        # $Name is bound from pipeline object's Name/Repository/Repo property
        Get-GitHubRepositoryByName -Owner $Owner -Name $Name -Context $Context
    }
}
```

**Usage:**

```powershell
# Pipeline array of repository names
@('repo1', 'repo2', 'repo3') | ForEach-Object {
    [pscustomobject]@{ Owner = 'octocat'; Name = $_ }
} | Get-GitHubRepository

# Pipeline from another command
Get-GitHubRepository -Owner 'octocat' | Get-GitHubRepositoryBranch
```

**Key Pattern Elements:**

- **`ValueFromPipelineByPropertyName`**: Bind parameter from pipeline object property with matching name or alias
- **Aliases for binding**: Use `[Alias()]` to accept multiple property names
- **Context not from pipeline**: Context parameter should never use `ValueFromPipeline` or `ValueFromPipelineByPropertyName`
- **Resolve context in `begin`**: Only resolve context once, not for each pipeline object

---

## Debug Output Pattern

### Comprehensive Debug Logging

```powershell
begin {
    $stackPath = Get-PSCallStackPath
    Write-Debug "[$stackPath] - Start"
    $debug = $DebugPreference -eq 'Continue'

    if ($debug) {
        Write-Debug 'Parent function parameters:'
        Get-FunctionParameter -Scope 1 | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        Write-Debug 'Parameters:'
        Get-FunctionParameter | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
    }
}

process {
    if ($debug) {
        Write-Debug '----------------------------------'
        Write-Debug 'Request:'
        [pscustomobject]$APICall | Select-Object -ExcludeProperty Body, Headers | Format-List |
            Out-String -Stream | ForEach-Object { Write-Debug $_ }
        Write-Debug '----------------------------------'
        Write-Debug 'Request headers:'
        [pscustomobject]$APICall.Headers | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        Write-Debug '----------------------------------'
        Write-Debug 'Request body:'
        ($APICall.Body | Out-String).Split('\n') -split '\n' | ForEach-Object { Write-Debug $_ }
        Write-Debug '----------------------------------'
    }

    # ... do work ...

    if ($debug) {
        Write-Debug '----------------------------------'
        Write-Debug 'Response:'
        $response | Select-Object -ExcludeProperty Content, Headers | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        Write-Debug '---------------------------'
        Write-Debug 'Response headers:'
        $headers | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        Write-Debug '---------------------------'
        Write-Debug 'Response content:'
        $results | ConvertTo-Json -Depth 5 -WarningAction SilentlyContinue | Out-String -Stream | ForEach-Object {
            $content = $_
            $content = $content -split '\n'
            $content = $content.Split('\n')
            foreach ($item in $content) {
                Write-Debug $item
            }
        }
        Write-Debug '---------------------------'
    }
}

end {
    Write-Debug "[$stackPath] - End"
}
```

**Key Pattern Elements:**

- **Stack path**: Use `Get-PSCallStackPath` to show function call hierarchy
- **Debug preference check**: Store `$debug = $DebugPreference -eq 'Continue'` to avoid repeated checks
- **Format for readability**: Use `Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }`
- **Separators**: Use `Write-Debug '----...'` to visually separate sections
- **Exclude large properties**: Use `-ExcludeProperty Body, Headers` when showing request object
- **Line-by-line output**: Split multi-line strings and debug each line separately
- **Begin and end markers**: Always include `Write-Debug "[$stackPath] - Start"` and `Write-Debug "[$stackPath] - End"`

---

## Summary

These patterns are extracted from the actual GitHub PowerShell module codebase. They demonstrate:

1. **Context Resolution**: How to resolve string/null/object contexts with token refresh
2. **API Calls**: Complete pattern for REST API calls with pagination, error handling, and structured responses
3. **Public Functions**: Filter-based with parameter sets, context resolution, and routing
4. **Private Functions**: Direct API mapping with mandatory context and type constructors
5. **Parameter Splatting**: Conditional hashtable building and cleaning
6. **Error Handling**: Structured error objects with comprehensive context
7. **GraphQL Queries**: Field mapping, variable separation, and type construction
8. **Filter Usage**: Streaming pipeline behavior for all functions
9. **Pipeline Support**: Property binding with aliases and context handling
10. **Debug Output**: Comprehensive logging with stack paths and structured output

When writing code for this module, refer to these concrete examples and follow the established patterns.
