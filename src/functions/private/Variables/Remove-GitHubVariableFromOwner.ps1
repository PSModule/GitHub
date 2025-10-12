function Remove-GitHubVariableFromOwner {
    <#
        .SYNOPSIS
        Delete an organization variable.

        .DESCRIPTION
        Deletes an organization variable using the variable name.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private,
        OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        ```pwsh
        Remove-GitHubVariableFromOwner -Owner 'octocat' -Name 'HOST_NAME' -Context $GitHubContext
        ```

        Deletes the specified variable from the specified organization.

        .NOTES
        [Delete an organization variable](https://docs.github.com/rest/actions/variables#delete-an-organization-variable)
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
        $apiParams = @{
            Method      = 'DELETE'
            APIEndpoint = "/orgs/$Owner/actions/variables/$Name"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("variable [$Name] on [$Owner]", 'Delete')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
