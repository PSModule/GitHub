
#List installations for the authenticated app
Invoke-RestMethod -Uri 'https://api.github.com/app/installations' -Headers @{
    Authorization = "Bearer $token"
}


#Get an organization installation for the authenticated app
Invoke-RestMethod -Uri 'https://api.github.com/orgs/psmodule/installation' -Headers @{
    Authorization = "Bearer $token"
}


#Get a repository installation for the authenticated app
Invoke-RestMethod -Uri 'https://api.github.com/repos/psmodule/.github/installation' -Headers @{
    Authorization = "Bearer $token"
}
