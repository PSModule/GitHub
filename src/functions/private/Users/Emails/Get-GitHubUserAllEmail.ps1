filter Get-GitHubUserAllEmail {
    <#
        .SYNOPSIS
        List email addresses for the authenticated user

        .DESCRIPTION
        Lists all of your email addresses, and specifies which one is visible to the public.
        This endpoint is accessible with the `user:email` scope.

        .EXAMPLE
        ```powershell
        Get-GitHubUserAllEmail
        ```

        Gets all email addresses for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/emails#list-email-addresses-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

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
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = '/user/emails'
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
