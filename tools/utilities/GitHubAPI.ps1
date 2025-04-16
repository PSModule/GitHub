# https://github.com/github/rest-api-description
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

$path = '/repos/{owner}/{repo}/releases/generate-notes'
$method = 'post'
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
$response.components.responses # HTTP status descriptions


$path = '/repos/{owner}/{repo}/actions/runs'
$method = 'get'


$specs = $response.components.schemas.PSObject.Properties | Sort-Object Name | ForEach-Object { [pscustomobject]@{ Name = $_.Name; Value = $_.Value } }
$response.components.schemas.'issue-comment'
$response.components.schemas.'workflow-run' | ConvertTo-Json -Depth 10 | Clip
$response.components.schemas.'workflow-run'.properties.PSObject.Properties | ForEach-Object {
    [pscustomobject]@{
        Name        = $_.Name
        Type        = $_.Value.format ?? $_.Value.type
        Example     = $_.Value.example
        Description = $_.Value.description
    }
} | Format-Table -AutoSize



$response.Info

$response.tags

$response.'x-webhooks'.'branch-protection-configuration-disabled'.post

$webhooks = @()
$response.'x-webhooks'.PSObject.Properties | ForEach-Object {
    $Name = $_.Name
    $_.Value.PSObject.Properties | ForEach-Object {
        $Type = $_.Name
        $Data = $_.Value
        $Supports = $Data.'x-github'.'supported-webhook-types'
        $Category = $Data.'x-github'.category
        $Subcategory = $Data.'x-github'.subcategory
        $CloudOnly = $Data.'x-github'.githubCloudOnly
        $SchemaID = $Data.requestBody.content.'application/json'.schema.'$ref' | Split-Path -Leaf
        $schema = $response.components.schemas.$SchemaID
        $schema | Add-Member -MemberType NoteProperty -Name ID -Value $SchemaID -Force
        $Properties = $schema.properties
        $Data | Add-Member -MemberType NoteProperty -Name Name -Value $Name -Force
        $Data | Add-Member -MemberType NoteProperty -Name Type -Value $Type -Force
        $Data | Add-Member -MemberType NoteProperty -Name Supports -Value $Supports -Force
        $Data | Add-Member -MemberType NoteProperty -Name Category -Value $Category -Force
        $Data | Add-Member -MemberType NoteProperty -Name Subcategory -Value $Subcategory -Force
        $Data | Add-Member -MemberType NoteProperty -Name CloudOnly -Value $CloudOnly -Force
        $Data | Add-Member -MemberType NoteProperty -Name Schema -Value $Schema -Force
        $Data | Add-Member -MemberType NoteProperty -Name Properties -Value $Properties -Force
        $webhooks += $Data
    }
}
$webhooks | Select-Object -Property Name, Type, Supports, Category, Subcategory, CloudOnly | Format-Table
$Data.name
$Data.parameters
$Data.responses
$Data.'x-github'
$Data.requestBody


$schema.title

$schema.properties.action.enum
$schema.required
