function New-GitHubVariableOnOwner {
    <#
        .SYNOPSIS
        Create an organization variable.

        .DESCRIPTION
        Creates an organization variable that you can reference in a GitHub Actions workflow.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private,
        OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        New-GitHubVariableOnOwner -Owner 'octocat' -Name 'HOST_NAME' -Value 'github.com' -Context $GitHubContext

        Creates a new organization variable named `HOST_NAME` with the value `github.com` in the specified organization.

        .NOTES
        [Create an organization variable](https://docs.github.com/rest/actions/variables#create-an-organization-variable)
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

        # The value of the variable.
        [Parameter(Mandatory)]
        [string] $Value,

        # The visibility of the variable. Can be `private`, `selected`, or `all`.
        # `private` - The variable is only available to the organization.
        # `selected` - The variable is available to selected repositories.
        # `all` - The variable is available to all repositories in the organization.
        [Parameter()]
        [ValidateSet('private', 'selected', 'all')]
        [string] $Visibility = 'private',

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
        $body = @{
            name       = $Name
            value      = $Value
            visibility = $Visibility
        }

        if ($Visibility -eq 'selected') {
            if (-not $SelectedRepositories) {
                throw 'You must specify the -SelectedRepositories parameter when using the -Visibility selected switch.'
            }
            $body['selected_repository_ids'] = $SelectedRepositories
        }

        $apiParams = @{
            Method      = 'POST'
            APIEndpoint = "/orgs/$Owner/actions/variables"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("variable [$Name] on [$Owner]", 'Create')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
