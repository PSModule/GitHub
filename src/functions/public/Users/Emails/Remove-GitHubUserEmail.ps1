﻿filter Remove-GitHubUserEmail {
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
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Email addresses associated with the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]] $Emails,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $body = @{
                emails = $Emails
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/user/emails'
                Method      = 'Delete'
                Body        = $body
            }

            if ($PSCmdlet.ShouldProcess("Email addresses [$($Emails -join ', ')]", 'Delete')) {
                $null = Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
