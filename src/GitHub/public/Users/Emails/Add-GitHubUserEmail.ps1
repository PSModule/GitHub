filter Add-GitHubUserEmail {
    <#
        .SYNOPSIS
        Add an email address for the authenticated user

        .DESCRIPTION
        This endpoint is accessible with the `user` scope.

        .EXAMPLE
        Add-GitHubUserEmail -Emails 'octocat@github.com','firstname.lastname@work.com'

        Adds the email addresses 'octocat@github.com' and 'firstname.lastname@work.com' to the authenticated user's account.

        .NOTES
        https://docs.github.com/rest/users/emails#add-an-email-address-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # Adds one or more email addresses to your GitHub account.
        # Must contain at least one email address.
        # Note: Alternatively, you can pass a single email address or an array of emails addresses directly,
        # but we recommend that you pass an object using the emails key.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]] $Emails
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case

    $inputObject = @{
        APIEndpoint = "/user/emails"
        Method      = 'POST'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
