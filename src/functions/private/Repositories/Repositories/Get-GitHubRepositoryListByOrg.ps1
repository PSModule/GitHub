filter Get-GitHubRepositoryListByOrg {
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
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubContextSetting -Name Owner),

        # Specifies the types of repositories you want returned.
        [Parameter()]
        [validateSet('all', 'public', 'private', 'forks', 'sources', 'member')]
        [string] $type = 'all',

        # The property to sort the results by.
        [Parameter()]
        [validateSet('created', 'updated', 'pushed', 'full_name')]
        [string] $Sort = 'created',

        # The order to sort by.
        # Default: asc when using full_name, otherwise desc.
        [Parameter()]
        [validateSet('asc', 'desc')]
        [string] $Direction,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
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
    Remove-HashtableEntry -Hashtable $body -RemoveNames 'Owner'

    $inputObject = @{
        APIEndpoint = "/orgs/$Owner/repos"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
