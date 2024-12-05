filter Get-GitHubBlockedUser {
    <#
        .SYNOPSIS
        List blocked users.

        .DESCRIPTION
        List the users that are blocked on your personal account or a given organization.

        .EXAMPLE
        Get-GitHubBlockedUser

        Returns a list of users blocked by the authenticated user.

        .EXAMPLE
        Get-GitHubBlockedUser -OrganizationName 'github'

        Lists all users blocked by the organization `github`.

        .NOTES
        [List users blocked by the authenticated user](https://docs.github.com/rest/users/blocking#list-users-blocked-by-the-authenticated-user)
        [List users blocked by an organization](https://docs.github.com/rest/orgs/blocking#list-users-blocked-by-an-organization)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('org')]
        [Alias('owner')]
        [Alias('login')]
        [string] $OrganizationName,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30,

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
        Get-GitHubBlockedUserByOrganization -OrganizationName $OrganizationName -PerPage $PerPage -Context $Context
    } else {
        Get-GitHubBlockedUserByUser -PerPage $PerPage -Context $Context
    }

}
