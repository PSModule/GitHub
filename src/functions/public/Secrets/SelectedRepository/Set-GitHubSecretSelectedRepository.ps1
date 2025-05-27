function Set-GitHubSecretSelectedRepository {
    <#
        .SYNOPSIS
        Set selected repositories for an organization secret.

        .DESCRIPTION
        Replaces all repositories for an organization secret when the `visibility` for repository access is set to `selected`. The visibility is set
        when you [Create or update an organization secret](https://docs.github.com/rest/actions/secrets#create-or-update-an-organization-secret).
        Authenticated users must have collaborator access to a repository to create, update, or read secrets. OAuth app tokens and personal access
        tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

        .EXAMPLE
        Set-GitHubSecretSelectedRepository -Owner 'octocat' -Name 'mysecret' -RepositoryID 1234567890

        Sets the selected repositories for the secret `mysecret` in the organization `octocat` to the repository with ID `1234567890`.        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/SelectedRepository/Set-GitHubSecretSelectedRepository/

                https://psmodule.io/GitHub/Functions/Secrets/SelectedRepository/Set-GitHubSecretSelectedRepository

        .NOTES
        [Set selected repositories for an organization secret](https://docs.github.com/rest/actions/secrets#set-selected-repositories-for-an-organization-secret)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Long links'
    )]
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the secret.
        [Parameter(Mandatory)]
        [string] $Name,

        # The ID of the repository to set to the secret.
        [Parameter(Mandatory)]
        [UInt64[]] $RepositoryID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            selected_repository_ids = @($RepositoryID)
        }
        $inputObject = @{
            Method      = 'PUT'
            APIEndpoint = "/orgs/$Owner/actions/secrets/$Name/repositories"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("access to secret [$Owner/$Name] for repository [$RepositoryID]", 'Set')) {
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
