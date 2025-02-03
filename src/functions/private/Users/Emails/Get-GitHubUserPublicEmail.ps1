﻿filter Get-GitHubUserPublicEmail {
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
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [GitHubContext] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $body = @{
                per_page = $PerPage
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/user/public_emails'
                Method      = 'GET'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
