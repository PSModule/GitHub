filter Remove-GitHubUserEmail {
    <#
        .SYNOPSIS
        Delete an email address for the authenticated user

        .DESCRIPTION
        This endpoint is accessible with the `user` scope.

        .EXAMPLE
        Remove-GitHubUserEmail -Emails 'octocat@github.com','firstname.lastname@work.com'

        Removes the email addresses `octocat@github.com` and `firstname.lastname@work.com` from the authenticated user's account.

        .NOTES
        [Delete an email address for the authenticated user](https://docs.github.com/rest/users/emails#delete-an-email-address-for-the-authenticated-user)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Emails/Remove-GitHubUserEmail
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        # Email addresses associated with the GitHub user account.
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

        $apiParams = @{
            Method      = 'DELETE'
            APIEndpoint = '/user/emails'
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Email addresses [$($Email -join ', ')]", 'DELETE')) {
            $null = Invoke-GitHubAPI @apiParams | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
