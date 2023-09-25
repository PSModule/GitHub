$APIDocURI = 'https://raw.githubusercontent.com/github/rest-api-description/main'
$Bundled = '/descriptions/api.github.com/api.github.com.json'
$Dereferenced = 'descriptions/api.github.com/dereferenced/api.github.com.deref.json'
$APIDocURI = $APIDocURI + $Bundled
$Response = Invoke-RestMethod -Uri $APIDocURI -Method Get

# $Response.info          # API name = GitHub REST API
# $Response.openapi       # Spec version = 3.0.3
# $Response.servers       # API URL = api.github.com
# $Response.externalDocs  # API docs URL = docs.github.com/rest
# $Response.components    # Type specs
# $Response.paths         # API endpoints
# $Response.tags          # API categories
# $Response.'x-webhooks'  # Webhooks/event docs


$Response.paths.'/meta'.get
