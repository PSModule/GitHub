filter Get-GitHubUserGpgKeyForUser {
    <#
        .SYNOPSIS
        List GPG keys for a user

        .DESCRIPTION
        Lists the GPG keys for a user. This information is accessible by anyone.

        .EXAMPLE
        Get-GitHubUserGpgKeyForUser -Username 'octocat'

        Gets all GPG keys for the 'octocat' user.

        .NOTES
        https://docs.github.com/rest/users/gpg-keys#list-gpg-keys-for-a-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [string] $Username,

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
            APIEndpoint = "/users/$Username/gpg_keys"
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
