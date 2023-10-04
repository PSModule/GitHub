filter Get-GitHubUser {
    <#
        .SYNOPSIS
        List user(s)

        .DESCRIPTION
        Get the authenticated user - if no parameters are provided.
        Get a given user - if a username is provided.
        Lists all users, in the order that they signed up on GitHub - if '-All' is provided.

        .EXAMPLE
        Get-GitHubUser

        Get the authenticated user.

        .EXAMPLE
        Get-GitHubUser -Username 'octocat'

        Get the 'octocat' user.

        .EXAMPLE
        Get-GitHubUser -All -Since 17722253

        Get a list of users, starting with the user 'MariusStorhaug'.

        .NOTES
        https://docs.github.com/rest/users/users
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(DefaultParameterSetName = '__DefaultSet')]
    param (
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ParameterSetName = 'NamedUser',
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

        # List all users. Use '-Since' to start at a specific user id.
        [Parameter(
            Mandatory,
            ParameterSetName = 'AllUsers'
        )]
        [switch] $All,

        # A user ID. Only return users with an ID greater than this ID.
        [Parameter(ParameterSetName = 'AllUsers')]
        [int] $Since = 0,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'AllUsers')]
        [int] $PerPage = 30
    )

    switch ($PSCmdlet.ParameterSetName) {
        '__DefaultSet' {
            $user = Get-GitHubMyUser
            $social_accounts = Get-GitHubMyUserSocials
            $user | Add-Member -MemberType NoteProperty -Name 'social_accounts' -Value $social_accounts -Force
            $user
        }
        'NamedUser' {
            $user = Get-GitHubUserByName -Username $Username
            $social_accounts = Get-GitHubUserSocialsByName -Username $Username
            $user | Add-Member -MemberType NoteProperty -Name 'social_accounts' -Value $social_accounts -Force
            $user
        }
        'AllUsers' {
            Get-GitHubAllUsers -Since $Since -PerPage $PerPage
        }
    }
}
