﻿filter Get-GitHubMyUserSocials {
    <#
        .SYNOPSIS
        List social accounts for the authenticated user

        .DESCRIPTION
        Lists all of your social accounts.

        .EXAMPLE
        Get-GitHubMyUserSocials

        Lists all of your social accounts.

        .NOTES
        https://docs.github.com/rest/users/social-accounts#list-social-accounts-for-the-authenticated-user
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Private function, not exposed to user.')]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

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
        $body = @{
            per_page = $PerPage
        }

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = '/user/social_accounts'
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
