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

        .OUTPUTS
        GitHubUser

        .NOTES
        [Get the authenticated user](https://docs.github.com/rest/users/users#get-the-authenticated-user)
    #>
    [OutputType([GitHubUser])]
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = '/user'
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            if ($_.Response.type -eq 'Organization') {
                [GitHubOrganization]::New($_.Response, $Context.HostName)
            } elseif ($_.Response.type -eq 'User') {
                [GitHubUser]::New($_.Response)
            } else {
                [GitHubOwner]::New($_.Response)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
