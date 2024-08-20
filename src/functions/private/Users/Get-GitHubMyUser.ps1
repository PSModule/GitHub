filter Get-GitHubMyUser {
    <#
        .SYNOPSIS
        Get the authenticated user

        .DESCRIPTION
        If the authenticated user is authenticated with an OAuth token with the `user` scope, then the response lists public
        and private profile information.
        If the authenticated user is authenticated through OAuth without the `user` scope, then the response lists only public
        profile information.

        .EXAMPLE
        Get-GitHubMyUser

        Get the authenticated user

        .NOTES
        https://docs.github.com/rest/users/users#get-the-authenticated-user
    #>
    [OutputType([pscustomobject])]
    [Alias('Get-GitHubContext')]
    [CmdletBinding()]
    param ()

    $inputObject = @{
        APIEndpoint = '/user'
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
