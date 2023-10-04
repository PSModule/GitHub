filter Block-GitHubUser {
    <#
        .SYNOPSIS
        Block a user from user or an organization.

        .DESCRIPTION
        Blocks the given user and returns true.
        If the user cannot be blocked false is returned.

        .EXAMPLE
        Block-GitHubUser -Username 'octocat'

        Blocks the user 'octocat' for the authenticated user.
        Returns $true if successful, $false if not.

        .EXAMPLE
        Block-GitHubUser -OrganizationName 'github' -Username 'octocat'

        Blocks the user 'octocat' from the organization 'github'.
        Returns $true if successful, $false if not.

        .NOTES
        https://docs.github.com/rest/users/blocking#block-a-user
        https://docs.github.com/rest/orgs/blocking#block-a-user-from-an-organization
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
        [string] $OrganizationName
    )

    if ($OrganizationName) {
        Block-GitHubUserByOrganization -OrganizationName $OrganizationName -Username $Username
    } else {
        Block-GitHubUserByUser -Username $Username
    }

}
