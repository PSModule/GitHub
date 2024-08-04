$APIDocURI = 'https://raw.githubusercontent.com/github/rest-api-description/main'
$Bundled = '/descriptions/api.github.com/api.github.com.json'
# $Dereferenced = 'descriptions/api.github.com/dereferenced/api.github.com.deref.json'
$APIDocURI = $APIDocURI + $Bundled
$response = Invoke-RestMethod -Uri $APIDocURI -Method Get

# $response.info          # API name = GitHub REST API
# $response.openapi       # Spec version = 3.0.3
# $response.servers       # API URL = api.github.com
# $response.externalDocs  # API docs URL = docs.github.com/rest
# $response.components    # Type specs
# $response.paths         # API endpoints # -> Namespaces, PascalCase!
# $response.tags          # API categories
# $response.'x-webhooks'  # Webhooks/event docs

# $response.paths.psobject.Properties | Select-Object `
#     Name, `
# @{n = 'Get'; e = { (($_.value.psobject.Properties.Name) -contains 'Get') } }, `
# @{n = 'Post'; e = { (($_.value.psobject.Properties.Name) -contains 'Post') } }, `
# @{n = 'Delete'; e = { (($_.value.psobject.Properties.Name) -contains 'Delete') } }, `
# @{n = 'PUT'; e = { (($_.value.psobject.Properties.Name) -contains 'PUT') } }, `
# @{n = 'PATCH'; e = { (($_.value.psobject.Properties.Name) -contains 'PATCH') } } | Format-Table

$path = '/repos/{owner}/{repo}/rulesets/rule-suites/{rule_suite_id}'
$method = 'get'
$response.paths.$path.$method
$response.paths.$path.$method.tags | clip                             # -> Namespace/foldername
$response.paths.$path.$method.operationId | clip                      # -> FunctionName
$response.paths.$path.$method.summary | clip                          # -> Synopsis
$response.paths.$path.$method.description | clip                      # -> Description
$response.paths.$path.$method.externalDocs.url | clip                 # -> Notes
$response.paths.$path.$method.'x-github'.category | clip              # -> Namespace/foldername
$response.paths.$path.$method.'x-github'.subcategory | clip           # -> Namespace/foldername
$response.paths.$path.$method.'x-github'.enabledForGitHubApps | clip  # -> Note + Warning if running as GitHub App
$response.paths.$path.$method.'x-github'.githubCloudOnly | clip       # -> Note
$response.paths.$path.$method.parameters                              # -> Parameter list
$response.paths.$path.$method.parameters.'$ref'                       # -> Parameter list
$response.components.parameters.username                              # -> Parameter list ?
$response.paths.$path.$method.responses                               # -> Could be used to decide error handling within the function
$response.paths.$path.$method.responses.'200'.content.'application/json'.schema        # -> OutputType qualifyer
$response.paths.$path.$method.responses.'200'.content.'application/json'.schema.items  # -> OutputType

$response.components.schemas.'issue-comment' | ConvertTo-Json

function Find-APIMethod {
    <#
        .SYNOPSIS
        Find API methods in a directory
    #>
    param (
        [Parameter(Mandatory)]
        [string] $SearchDirectory,

        [Parameter(Mandatory)]
        [string] $Method,

        [Parameter(Mandatory)]
        [string] $Path
    )

    $pathPattern = $Path -replace '\{[^}]+\}', '.+'
    $methodPattern = "Method\s*=\s*'$method'"
    Get-ChildItem -Path $SearchDirectory -Recurse -Filter *.ps1 | ForEach-Object {
        $filePath = $_.FullName
        $stringMatches = Select-String -Path $filePath -Pattern $pathPattern -AllMatches
        if ($stringMatches.Count -gt 0) {
            $putMatches = Select-String -Path $filePath -Pattern $methodPattern -AllMatches
            foreach ($match in $stringMatches) {
                foreach ($putMatch in $putMatches) {
                    Write-Verbose "Match found in file: $filePath"
                    Write-Verbose "API Endpoint: $($match.Matches.Value) near line $($match.LineNumber)"
                    Write-Verbose "Method: $($putMatch.Matches.Value) near line $($putMatch.LineNumber)"
                    return $true
                }
            }
        }
    }
    return $false
}

# Get a list of all
$functions = 0
$coveredFunctions = 0
$paths = [System.Collections.Generic.List[pscustomobject]]::new()
$SearchDirectory = 'C:\Repos\GitHub\PSModule\Module\GitHub\src'
$response.paths.PSObject.Properties | ForEach-Object {
    $path = $_.Name
    $object = [pscustomobject]@{
        Path   = $path
        DELETE = ''
        GET    = ''
        PATCH  = ''
        POST   = ''
        PUT    = ''
    }
    $_.Value.psobject.Properties.Name | ForEach-Object {
        $method = $_.ToUpper()
        $found = Find-APIMethod -SearchDirectory $SearchDirectory -Method $method -Path $path
        $object.$method = $found -contains $true ? ':white_check_mark:' : ':x:'
        if ($found) {
            $coveredFunctions++
        }
        $functions++
    }
    $paths.Add($object)
}
$paths | New-MDTable | clip

# Output the context of $paths to a markdown table and into the Coverage.md file
$paths | New-MDTable | Out-File -FilePath '.\Coverage.md'

"Available functions: $functions"
"Covered functions:   $coveredFunctions"
"Missing function:    $($functions - $coveredFunctions)"
"Coverage:            $([math]::Round(($coveredFunctions / $functions) * 100, 2))%"
