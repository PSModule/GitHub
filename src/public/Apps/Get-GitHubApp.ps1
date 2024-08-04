
#Get the authenticated app
Invoke-RestMethod -Uri 'https://api.github.com/app' -Headers @{
    Authorization = "Bearer $token"
}
