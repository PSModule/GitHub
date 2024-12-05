﻿filter Unblock-GitHubUser {
    <#
        .SYNOPSIS
        Unblock a user

        .DESCRIPTION
        Unblocks the given user and returns true.

        .EXAMPLE
        Unblock-GitHubUser -Username 'octocat'

        Unblocks the user 'octocat' for the authenticated user.
        Returns $true if successful.

        .EXAMPLE
        Unblock-GitHubUser -OrganizationName 'GitHub' -Username 'octocat'

        Unblocks the user 'octocat' from the organization 'GitHub'.
        Returns $true if successful.

        .NOTES
        [Unblock a user](https://docs.github.com/rest/users/blocking#unblock-a-user)
        [Unblock a user from an organization](https://docs.github.com/rest/orgs/blocking#unblock-a-user-from-an-organization)
    #>
    [OutputType([bool])]
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
        [Alias('org')]
        [Alias('owner')]
        [string] $OrganizationName,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    if ([string]::IsNullOrEmpty($Owner)) {
        $OrganizationName = $Context.Owner
    }
    Write-Debug "OrganizationName : [$($Context.Owner)]"

    if ($OrganizationName) {
        Unblock-GitHubUserByOrganization -OrganizationName $OrganizationName -Username $Username -Context $Context
    } else {
        Unblock-GitHubUserByUser -Username $Username -Context $Context
    }
}
