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


$response.paths.'/meta'.get


$response.paths.'/user'.get
