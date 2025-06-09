filter Add-GitHubUserEmail {
    <#
        .SYNOPSIS
        Add an email address for the authenticated user

        .DESCRIPTION
        This endpoint is accessible with the `user` scope.

        .EXAMPLE
        Add-GitHubUserEmail -Email 'octocat@github.com','firstname.lastname@work.com'

        Adds the email addresses `octocat@github.com` and `firstname.lastname@work.com` to the authenticated user's account.

        .NOTES
        [Add an email address for the authenticated user](https://docs.github.com/rest/users/emails#add-an-email-address-for-the-authenticated-user)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Emails/Add-GitHubUserEmail
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # Adds one or more email addresses to your GitHub account.
        # Must contain at least one email address.
        # Note: Alternatively, you can pass a single email address or an array of emails addresses directly,
        # but we recommend that you pass an object using the emails key.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]] $Email,

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
        $body = @{
            emails = $Email
        }

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = '/user/emails'
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
