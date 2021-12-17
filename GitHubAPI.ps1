$APIDocURI = 'https://raw.githubusercontent.com/github/rest-api-description/main/descriptions/api.github.com/api.github.com.json'
$Response = Invoke-WebRequest -Uri $APIDocURI -Method Get -UseBasicParsing
$APIDoc = $Response.Content | ConvertFrom-Json
$APIDoc.tags
