﻿filter Test-GitHubBlockedUser {
    <#
        .SYNOPSIS
        Check if a user is blocked by the authenticated user or an organization.

        .DESCRIPTION
        Returns a 204 if the given user is blocked by the authenticated user or organization.
        Returns a 404 if the given user is not blocked, or if the given user account has been identified as spam by GitHub.

        .EXAMPLE
        Test-GitHubBlockedUser -Username 'octocat'

        Checks if the user `octocat` is blocked by the authenticated user.
        Returns true if the user is blocked, false if not.

        .EXAMPLE
        Test-GitHubBlockedUser -Organization 'github' -Username 'octocat'

        Checks if the user `octocat` is blocked by the organization `github`.
        Returns true if the user is blocked, false if not.

        .NOTES
        [Check if a user is blocked by the authenticated user](https://docs.github.com/rest/users/blocking#check-if-a-user-is-blocked-by-the-authenticated-user)
        [Check if a user is blocked by an organization](https://docs.github.com/rest/orgs/blocking#check-if-a-user-is-blocked-by-an-organization)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Blocking/Test-GitHubBlockedUser
    #>
    [OutputType([bool])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding()]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [string] $Username,

        # The organization name. The name is not case sensitive.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Organization,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        if ([string]::IsNullOrEmpty($Organization)) {
            $Organization = $Context.Owner
        }
        Write-Debug "Organization: [$Organization]"
    }

    process {
        if ($Organization) {
            Test-GitHubBlockedUserByOrganization -Organization $Organization -Username $Username -PerPage $PerPage -Context $Context
        } else {
            Test-GitHubBlockedUserByUser -Username $Username -PerPage $PerPage -Context $Context
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
