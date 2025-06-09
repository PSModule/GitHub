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
        [List public email addresses for the authenticated user](https://docs.github.com/rest/users/emails#list-public-email-addresses-for-the-authenticated-user)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Emails/Get-GitHubUserEmail
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding()]
    param(
        # Get the publicly visible email address for the authenticated user.
        [Parameter()]
        [switch] $Public,

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
    }

    process {
        $params = @{
            PerPage = $PerPage
            Context = $Context
        }
        if ($Public) {
            Get-GitHubUserPublicEmail @params
        } else {
            Get-GitHubUserAllEmail @params
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
