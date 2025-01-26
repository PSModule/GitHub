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
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/user'
                Method      = 'GET'
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
