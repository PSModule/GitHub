#region As a user: get the authenticated user
Connect-GitHub

# Simple example - output is the object
Get-GitHubUser

# More complex example - output is parts of the web response
Invoke-GitHubAPI -ApiEndpoint /user

# Most complex example - output is the entire web response
$context = Get-GitHubContext
Invoke-WebRequest -Uri "https://api.$($context.HostName)/user" -Token ($context.Token) -Authentication Bearer
#endregion


#region As an app: get the authenticated app
$ClientID = ''
$PrivateKey = ''
Connect-GitHub -ClientID $ClientID -PrivateKey $PrivateKey

# Simple example - output is the object
Get-GitHubApp

# More complex example - output is parts of the web response
Invoke-GitHubAPI -ApiEndpoint /app

# Most complex example - output is the entire web response
$context = Get-GitHubContext
$jwt = Get-GitHubAppJSONWebToken -ClientId $context.ClientID -PrivateKey $context.Token
Invoke-WebRequest -Uri "https://api.$($context.HostName)/user" -Token ($jwt.token) -Authentication Bearer
#endregion


#region As an app installation: get zen
Connect-GitHubApp -Installation 'PSModule'

# Simple example - output is the object
Get-GitHuben

# More complex example - output is parts of the web response
Invoke-GitHubAPI -ApiEndpoint /zen

# Most complex example - output is the entire web response
$context = Get-GitHubContext
Invoke-WebRequest -Uri "https://api.$($context.HostName)/zen" -Token ($context.Token) -Authentication Bearer
Invoke-RestMethod -Uri "https://api.$($context.HostName)/octocat" -Token ($context.Token) -Authentication Bearer
#endregion
