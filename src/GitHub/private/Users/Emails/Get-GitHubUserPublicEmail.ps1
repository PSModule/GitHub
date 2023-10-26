filter Get-GitHubUserPublicEmail {
    <#
        .SYNOPSIS
        List public email addresses for the authenticated user

        .DESCRIPTION
        Lists your publicly visible email address, which you can set with the
        [Set primary email visibility for the authenticated user](https://docs.github.com/rest/users/emails#set-primary-email-visibility-for-the-authenticated-user)
        endpoint. This endpoint is accessible with the `user:email` scope.

        .EXAMPLE
        Get-GitHubUserPublicEmail

        Gets all public email addresses for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/emails#list-public-email-addresses-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Link to documentation.')]
    [CmdletBinding()]
    param (
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case

    $inputObject = @{
        APIEndpoint = '/user/public_emails'
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
