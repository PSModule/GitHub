﻿filter Get-GitHubUserKeyForUser {
    <#
        .SYNOPSIS
        List public SSH keys for a user

        .DESCRIPTION
        Lists the _verified_ public SSH keys for a user. This is accessible by anyone.

        .EXAMPLE
        Get-GitHubUserKeyForUser -Username 'octocat'

        Gets all public SSH keys for the 'octocat' user.

        .NOTES
        https://docs.github.com/rest/users/keys#list-public-keys-for-a-user

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
            APIEndpoint = "/users/$Username/keys"
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
