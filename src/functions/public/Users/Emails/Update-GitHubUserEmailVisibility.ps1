﻿filter Update-GitHubUserEmailVisibility {
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
        [Set primary email visibility for the authenticated user](https://docs.github.com/rest/users/emails#set-primary-email-visibility-for-the-authenticated-user)
    #>
    #SkipTest:FunctionTest:Will add a test for this function in a future PR
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Denotes whether an email is publicly visible.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateSet('public', 'private')]
        [string] $Visibility,

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
                visibility = $Visibility
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/user/email/visibility'
                Method      = 'PATCH'
                Body        = $body
            }

            if ($PSCmdlet.ShouldProcess("Email visibility [$Visibility]", 'Set')) {
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
