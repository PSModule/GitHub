﻿filter Get-GitHubBlockedUser {
    <#
        .SYNOPSIS
        List users blocked by the authenticated user

        .DESCRIPTION
        List the users you've blocked on your personal account.

        .EXAMPLE

        .NOTES
        https://docs.github.com/rest/users/blocking#list-users-blocked-by-the-authenticated-user
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The number of results per page (max 100).
        [Parameter()]
        [int] $PerPage = 30
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case

    $inputObject = @{
        APIEndpoint = "/user/blocks"
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}