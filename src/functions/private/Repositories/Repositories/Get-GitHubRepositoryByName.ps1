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
        Get-GitHubRepositoryByName -Owner 'octocat' -Name 'Hello-World'

        Gets the repository 'Hello-World' for the organization 'octocat'.

        .NOTES
        https://docs.github.com/rest/repos/repos#get-a-repository

    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Name,

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
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Name"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $_.Response | ForEach-Object {
                [GitHubRepository]::New($_)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
