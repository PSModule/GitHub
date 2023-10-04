filter Test-GitHubBlockedUser {
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
        Test-GitHubBlockedUser -OrganizationName 'github' -Username 'octocat'

        Checks if the user `octocat` is blocked by the organization `github`.
        Returns true if the user is blocked, false if not.

        .NOTES
        https://docs.github.com/rest/users/blocking#check-if-a-user-is-blocked-by-the-authenticated-user
        https://docs.github.com/rest/orgs/blocking#check-if-a-user-is-blocked-by-an-organization
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
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
        [Alias('login')]
        [string] $OrganizationName,

        # The number of results per page (max 100).
        [Parameter()]
        [int] $PerPage = 30
    )

    if ($OrganizationName) {
        Test-GitHubBlockedUserByOrganization -OrganizationName $OrganizationName -Username $Username -PerPage $PerPage
    } else {
        Test-GitHubBlockedUserByUser -Username $Username -PerPage $PerPage
    }

}
