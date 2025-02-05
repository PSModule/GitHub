﻿filter Get-GitHubRepositoryListByOrg {
    <#
        .SYNOPSIS
        List organization repositories

        .DESCRIPTION
        Lists repositories for the specified organization.
        **Note:** In order to see the `security_and_analysis` block for a repository you must have admin permissions for the repository
        or be an owner or security manager for the organization that owns the repository.
        For more information, see "[Managing security managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization)."

        .EXAMPLE
        Get-GitHubRepositoryListByOrg -Owner 'octocat'

        Gets the repositories for the organization 'octocat'.

        .EXAMPLE
        Get-GitHubRepositoryListByOrg -Owner 'octocat' -Type 'public'

        Gets the public repositories for the organization 'octocat'.

        .EXAMPLE
        Get-GitHubRepositoryListByOrg -Owner 'octocat' -Sort 'created' -Direction 'asc'

        Gets the repositories for the organization 'octocat' sorted by creation date in ascending order.

        .NOTES
        https://docs.github.com/rest/repos/repos#list-organization-repositories

    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # Specifies the types of repositories you want returned.
        [Parameter()]
        [ValidateSet('all', 'public', 'private', 'forks', 'sources', 'member')]
        [string] $Type = 'all',

        # The property to sort the results by.
        [Parameter()]
        [ValidateSet('created', 'updated', 'pushed', 'full_name')]
        [string] $Sort = 'created',

        # The order to sort by.
        # Default: asc when using full_name, otherwise desc.
        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string] $Direction,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            sort      = $Sort
            type      = $Type
            direction = $Direction
            per_page  = $PerPage
        }

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Owner/repos"
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
