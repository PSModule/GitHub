filter New-GitHubRepositoryAsFork {
    <#
        .SYNOPSIS
        Create a fork

        .DESCRIPTION
        Create a fork for the authenticated user.

        **Note**: Forking a Repository happens asynchronously. You may have to wait a short period of time before you can access the git objects.
        If this takes longer than 5 minutes, be sure to contact [GitHub Support](https://support.github.com/contact?tags=dotcom-rest-api).

        **Note**: Although this endpoint works with GitHub Apps, the GitHub App must be installed on the destination account with access to all
        repositories and on the source account with access to the source repository.

        .EXAMPLE
        New-GitHubRepositoryAsFork -ForkOwner 'github' -ForkRepo 'Hello-World'

        Fork the repository `Hello-World` owned by `github` for the authenticated user.
        Repo will be named `Hello-World`, and all branches and tags will be forked.

        .EXAMPLE
        New-GitHubRepositoryAsFork -ForkOwner 'github' -ForkRepo 'Hello-World' -Name 'Hello-World-2'

        Fork the repository `Hello-World` owned by `github` for the authenticated user, naming the resulting repository `Hello-World-2`.

        .EXAMPLE
        New-GitHubRepositoryAsFork -ForkOwner 'github' -ForkRepo 'Hello-World' -Organization 'octocat'

        Fork the repository `Hello-World` owned by `github` for the organization `octocat`, naming the resulting repository `Hello-World`.

        .EXAMPLE
        New-GitHubRepositoryAsFork -ForkOwner 'github' -ForkRepo 'Hello-World' -DefaultBranchOnly

        Fork the repository `Hello-World` owned by `github` for the authenticated user, forking only the default branch.

        .NOTES
        https://docs.github.com/rest/repos/forks#create-a-fork

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repo,

        # The organization or person who will own the new repository.
        # To create a new repository in an organization, the authenticated user must be a member of the specified organization.
        [Parameter()]
        [string] $Organization = (Get-GitHubConfig -Name Owner),

        # The name of the new repository.
        [Parameter()]
        [string] $Name,

        # When forking from an existing repository, fork with only the default branch.
        [Parameter()]
        [Alias('default_branch_only')]
        [switch] $DefaultBranchOnly
    )

    if ([string]::IsNullorEmpty($Name)) {
        $Name = $ForkRepo
    }

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
    Remove-HashtableEntry -Hashtable $body -RemoveNames 'ForkOwner', 'ForkRepo' -RemoveTypes 'SwitchParameter'

    $body['default_branch_only'] = $DefaultBranchOnly -eq $true

    $inputObject = @{
        APIEndpoint = "/repos/$ForkOwner/$ForkRepo/forks"
        Method      = 'POST'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("Repository [$Owner/$Name] as fork of [$ForkOwner/$ForkRepo]", 'Create')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
