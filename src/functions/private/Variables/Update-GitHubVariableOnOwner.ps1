function Update-GitHubVariableOnOwner {
    <#
        .SYNOPSIS
        Update an organization variable.

        .DESCRIPTION
        Updates an organization variable that you can reference in a GitHub Actions workflow.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private,
        the `repo` scope is also required.

        .EXAMPLE
        ```powershell
        Update-GitHubVariableOnOwner -Owner 'octocat' -Name 'HOST_NAME' -Value 'github.com' -Context $GitHubContext
        ```

        Updates the organization variable named `HOST_NAME` with the value `github.com` in the specified organization.

        .NOTES
        [Update an organization variable](https://docs.github.com/rest/actions/variables#update-an-organization-variable)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the variable.
        [Parameter(Mandatory)]
        [string] $Name,

        # The new name of the variable.
        [Parameter()]
        [string] $NewName,

        # The value of the variable.
        [Parameter()]
        [string] $Value,

        # The visibility of the variable. Can be `private`, `selected`, or `all`.
        # `private` - The variable is only available to the organization.
        # `selected` - The variable is available to selected repositories.
        # `all` - The variable is available to all repositories in the organization.
        [Parameter()]
        [ValidateSet('private', 'selected', 'all')]
        [string] $Visibility,

        # The IDs of the repositories to which the variable is available.
        # This parameter is only used when the `-Visibility` parameter is set to `selected`.
        # The IDs can be obtained from the `Get-GitHubRepository` function.
        [Parameter()]
        [UInt64[]] $SelectedRepositories,

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
        $body = @{}
        if ($PSBoundParameters.ContainsKey('NewName')) {
            $body.name = $NewName
        }
        if ($PSBoundParameters.ContainsKey('Value')) {
            $body.value = $Value
        }
        if ($PSBoundParameters.ContainsKey('Visibility')) {
            $body.visibility = $Visibility
        }
        if ($PSBoundParameters.ContainsKey('SelectedRepositories')) {
            $body.selected_repository_ids = $SelectedRepositories
        }

        if ($Visibility -eq 'selected') {
            if (-not $SelectedRepositories) {
                throw 'You must specify the -SelectedRepositories parameter when using the -Visibility selected switch.'
            }
            $body['selected_repository_ids'] = $SelectedRepositories
        }

        $apiParams = @{
            Method      = 'PATCH'
            APIEndpoint = "/orgs/$Owner/actions/variables/$Name"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("variable [$Name] on [$Owner]", 'Update')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
