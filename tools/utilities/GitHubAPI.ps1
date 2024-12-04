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

$path = '/app/hook/deliveries/{delivery_id}'
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


function New-Function {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $Method
    )

    $APIDocURI = 'https://raw.githubusercontent.com/github/rest-api-description/main'
    $Bundled = '/descriptions/api.github.com/api.github.com.json'
    # $Dereferenced = 'descriptions/api.github.com/dereferenced/api.github.com.deref.json'
    $APIDocURI = $APIDocURI + $Bundled
    $response = Invoke-RestMethod -Uri $APIDocURI -Method Get

    $response.paths.$Path.$Method

    $FunctionName = "$Method-GitHub" + (($response.paths.$path.$method.operationId) -Replace '/', '-')

    $folderName = $response.paths.$path.$method.'x-github'.category
    $subFolderName = $response.paths.$path.$method.'x-github'.subcategory

    $template = @"
    function $FunctionName {
        <#
            .SYNOPSIS
            $($response.paths.$path.$method.summary)

            .DESCRIPTION
            $($response.paths.$path.$method.description)

            .EXAMPLE
            An example

            .NOTES
            [$($response.paths.$path.$method.summary)]($($response.paths.$path.$method.externalDocs.url))
        #>
        [OutputType([pscustomobject])]
        [CmdletBinding()]
        param(
            # The context to run the command in.
            [Parameter()]
            [string] `$Context = (Get-GitHubConfig -Name 'DefaultContext')
        )
    }
"@
    if ($PSCmdlet.ShouldProcess('Function', 'Create')) {
        New-Item -Path "src/functions/$folderName/$subFolderName" -Name "$FunctionName.ps1" -ItemType File -Value $template
    }

}
