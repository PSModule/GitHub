filter Set-GitHubUserEmailVisibility {
    <#
        .SYNOPSIS
        Set primary email visibility for the authenticated user

        .DESCRIPTION
        Sets the visibility for your primary email addresses.

        .EXAMPLE
        Set-GitHubUserEmailVisibility -Visibility public

        Sets the visibility for your primary email addresses to public.

        .EXAMPLE
        Set-GitHubUserEmailVisibility -Visibility private

        Sets the visibility for your primary email addresses to private.

        .NOTES
        https://docs.github.com/rest/users/emails#set-primary-email-visibility-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # Denotes whether an email is publicly visible.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateSet('public', 'private')]
        [string] $Visibility
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case

    $inputObject = @{
        APIEndpoint = "/user/email/visibility"
        Method      = 'PATCH'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
