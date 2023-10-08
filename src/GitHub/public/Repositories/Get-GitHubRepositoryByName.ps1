filter Get-GitHubRepositoryByName {
    <#
        .SYNOPSIS
        Get a repository

        .DESCRIPTION
        The `parent` and `source` objects are present when the repository is a fork.
        `parent` is the repository this repository was forked from, `source` is the ultimate source for the network.
        **Note:** In order to see the `security_and_analysis` block for a repository you must have admin permissions
        for the repository or be an owner or security manager for the organization that owns the repository.
        For more information, see "[Managing security managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization)."

        .EXAMPLE
        Get-GitHubRepositoryByName -Owner 'octocat' -Repo 'Hello-World'

        Gets the repository 'Hello-World' for the organization 'octocat'.

        .NOTES
        https://docs.github.com/rest/repos/repos#get-a-repository

    #>
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo)

    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
        Write-Verbose "Request: $($_.Request | ConvertFrom-Json | Out-String)"
        Write-Verbose "StatusCode: $($_.StatusCode)"
        Write-Verbose "ResponseHeaders: $($_.ResponseHeaders | ConvertFrom-Json | Out-String)"
    }

}
