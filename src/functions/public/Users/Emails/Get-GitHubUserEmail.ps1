filter Get-GitHubUserEmail {
    <#
        .SYNOPSIS
        List email addresses for the authenticated user

        .DESCRIPTION
        Lists all of your email addresses, and specifies which one is visible to the public. This endpoint is accessible with the `user:email` scope.
        Specifying '-Public' will return only the publicly visible email address, which you can set with the [Set primary email visibility for the
        authenticated user](https://docs.github.com/rest/users/emails#set-primary-email-visibility-for-the-authenticated-user) endpoint.

        .EXAMPLE
        Get-GitHubUserEmail

        Gets all email addresses for the authenticated user.

        .EXAMPLE
        Get-GitHubUserEmail -Public

        Gets the publicly visible email address for the authenticated user.

        .NOTES
        [List email addresses for the authenticated user](https://docs.github.com/rest/users/emails#list-email-addresses-for-the-authenticated-user)
        [List public email addresses for the authenticated user](https://docs.github.com/en/rest/users/emails#list-public-email-addresses-for-the-authenticated-user)

    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30,

        [Parameter()]
        [switch] $Public,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    if ($Public) {
        Get-GitHubUserPublicEmail -PerPage $PerPage -Context $Context
    } else {
        Get-GitHubUserAllEmail -PerPage $PerPage -Context $Context
    }
}
