filter Move-GitHubRepository {
    <#
        .SYNOPSIS
        Transfer a repository

        .DESCRIPTION
        A transfer request will need to be accepted by the new owner when transferring a personal repository to another user. The response will contain the original `owner`, and the transfer will continue asynchronously. For more details on the requirements to transfer personal and organization-owned repositories, see [about repository transfers](https://docs.github.com/articles/about-repository-transfers/).
        You must use a personal access token (classic) or an OAuth token for this endpoint. An installation access token or a fine-grained personal access token cannot be used because they are only granted access to a single account.

        .EXAMPLE
        Move-GitHubRepository -Owner 'PSModule' -Repo 'GitHub' -NewOwner 'GitHub' -NewName 'PowerShell'

        Moves the GitHub repository to the PSModule organization and renames it to GitHub.

        .NOTES
        https://docs.github.com/rest/repos/repos#transfer-a-repository

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

        # The username or organization name the repository will be transferred to.
        [Parameter(Mandatory)]
        [Alias('new_owner')]
        [string] $NewOwner,

        # The new name to be given to the repository.
        [Parameter()]
        [Alias('new_name')]
        [string] $NewName,

        # ID of the team or teams to add to the repository. Teams can only be added to organization-owned repositories.
        [Parameter()]
        [Alias('team_ids')]
        [int[]] $TeamIds
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
    Remove-HashtableEntries -Hashtable $body -RemoveNames 'Owner','Repo' -RemoveTypes 'SwitchParameter'

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/transfer"
        Method      = 'POST'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
