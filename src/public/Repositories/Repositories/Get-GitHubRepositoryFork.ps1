﻿filter Get-GitHubRepositoryFork {
    <#
        .SYNOPSIS
        List forks

        .DESCRIPTION
        List forks of a named repository.

        .EXAMPLE
        Get-GitHubRepositoryFork -Owner 'octocat' -Repo 'Hello-World'

        List forks of the 'Hello-World' repository owned by 'octocat'.

        .NOTES
        [List forks](https://docs.github.com/rest/repos/forks#list-forks)

    #>
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The direction to sort the results by.
        [Parameter()]
        [ValidateSet('newest', 'oldest', 'stargazers', 'watchers')]
        [string] $Sort = 'newest',

        # The number of results per page.
        [Parameter()]
        [ValidateRange(1, 100)]
        [Alias('per_page')]
        [int] $PerPage = 30
    )

    $PSCmdlet.MyInvocation.MyCommand.Parameters.GetEnumerator() | ForEach-Object {
        $paramName = $_.Key
        $paramDefaultValue = Get-Variable -Name $paramName -ValueOnly -ErrorAction SilentlyContinue
        $providedValue = $PSBoundParameters[$paramName]
        Write-Verbose "[$paramName]"
        Write-Verbose "  - Default:  [$paramDefaultValue]"
        Write-Verbose "  - Provided: [$providedValue]"
        if (-not $PSBoundParameters.ContainsKey($paramName) -and ($null -ne $paramDefaultValue)) {
            Write-Verbose '  - Using default value'
            $PSBoundParameters[$paramName] = $paramDefaultValue
        } else {
            Write-Verbose '  - Using provided value'
        }
    }

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntry -Hashtable $body -RemoveNames 'Owner', 'Repo' -RemoveTypes 'SwitchParameter'

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/forks"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
