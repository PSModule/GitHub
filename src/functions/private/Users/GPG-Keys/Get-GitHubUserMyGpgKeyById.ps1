﻿filter Get-GitHubUserMyGpgKeyById {
    <#
        .SYNOPSIS
        Get a GPG key for the authenticated user

        .DESCRIPTION
        View extended details for a single GPG key.
        Requires that you are authenticated via Basic Auth or via OAuth with at least `read:gpg_key`
        [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        Get-GitHubUserMyGpgKeyById -ID '1234567'

        Gets the GPG key with ID '1234567' for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/gpg-keys#get-a-gpg-key-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The ID of the GPG key.
        [Parameter(
            Mandatory
        )]
        [Alias('gpg_key_id')]
        [string] $ID,

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
            APIEndpoint = "/user/gpg_keys/$ID"
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
