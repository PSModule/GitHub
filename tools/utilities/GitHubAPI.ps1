$APIDocURI = 'https://raw.githubusercontent.com/github/rest-api-description/main'
$Bundled = '/descriptions/api.github.com/api.github.com.json'
$Dereferenced = 'descriptions/api.github.com/dereferenced/api.github.com.deref.json'
$APIDocURI = $APIDocURI + $Bundled
$response = Invoke-RestMethod -Uri $APIDocURI -Method Get

# $response.info          # API name = GitHub REST API
# $response.openapi       # Spec version = 3.0.3
# $response.servers       # API URL = api.github.com
# $response.externalDocs  # API docs URL = docs.github.com/rest
# $response.components    # Type specs
# $response.paths         # API endpoints
# $response.tags          # API categories
# $response.'x-webhooks'  # Webhooks/event docs

$path = '/users/{username}/hovercard'
$response.paths.$path.get.tags | clip                            # -> Namespace/foldername
$response.paths.$path.get.operationId | clip                      # -> FunctionName
$response.paths.$path.get.summary | clip                          # -> Synopsis
$response.paths.$path.get.description | clip                      # -> Description
$response.paths.$path.get.externalDocs.url | clip                 # -> Notes
$response.paths.$path.get.'x-github'.category | clip              # -> Namespace/foldername
$response.paths.$path.get.'x-github'.subcategory | clip           # -> Namespace/foldername
$response.paths.$path.get.'x-github'.enabledForGitHubApps | clip  # -> Note + Warning if running as GitHub App
$response.paths.$path.get.'x-github'.githubCloudOnly | clip       # -> Note
$response.paths.$path.get.parameters                              # -> Parameter list
$response.paths.$path.get.responses.'200'.content.'application/json'.schema        # -> OutputType qualifyer
$response.paths.$path.get.responses.'200'.content.'application/json'.schema.items  # -> OutputType
$response.paths.$path.get

