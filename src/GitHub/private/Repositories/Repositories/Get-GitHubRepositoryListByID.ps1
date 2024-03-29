﻿filter Get-GitHubRepositoryListByID {
    <#
        .SYNOPSIS
        List public repositories

        .DESCRIPTION
        Lists all public repositories in the order that they were created.

        Note:
        - For GitHub Enterprise Server, this endpoint will only list repositories available to all users on the enterprise.
        - Pagination is powered exclusively by the `since` parameter. Use the
        [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers)
        to get the URL for the next page of repositories.

        .EXAMPLE
        Get-GitHubRepositoryListByID -Since '123456789

        Gets the repositories with an ID equals and greater than 123456789.

        .NOTES
        https://docs.github.com/rest/repos/repos#list-public-repositories

    #>
    [CmdletBinding()]
    param (
        # A repository ID. Only return repositories with an ID greater than this ID.
        [Parameter()]
        [int] $Since = 0
    )

    $PSCmdlet.MyInvocation.MyCommand.Parameters.GetEnumerator() | ForEach-Object {
        Write-Verbose "Parameter: [$($_.Key)] = [$($_.Value)]"
        $paramDefaultValue = Get-Variable -Name $_.Key -ValueOnly -ErrorAction SilentlyContinue
        if (-not $PSBoundParameters.ContainsKey($_.Key) -and ($null -ne $paramDefaultValue)) {
            Write-Verbose "Parameter: [$($_.Key)] = [$($_.Value)] - Adding default value"
            $PSBoundParameters[$_.Key] = $paramDefaultValue
        }
        Write-Verbose " - $($PSBoundParameters[$_.Key])"
    }

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case

    $inputObject = @{
        APIEndpoint = '/repositories'
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
