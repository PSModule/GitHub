filter Remove-GitHubRepository {
    <#
        .SYNOPSIS
        Delete a repository

        .DESCRIPTION
        Deleting a repository requires admin access. If OAuth is used, the `delete_repo` scope is required.

        If an organization owner has configured the organization to prevent members from deleting organization-owned
        repositories, you will get a `403 Forbidden` response.

        .EXAMPLE
        Remove-GitHubRepository -Owner 'PSModule' -Name 'Hello-World'

        Deletes the repository `Hello-World` in the `PSModule` organization.

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Remove-GitHubRepository/

        .LINK
        [Delete a repository](https://docs.github.com/rest/repos/repos#delete-a-repository)
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

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
        $inputObject = @{
            Method      = 'DELETE'
            APIEndpoint = "/repos/$Owner/$Name"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("repo [$Owner/$Name]", 'Delete')) {
            $null = Invoke-GitHubAPI @inputObject
            Write-Verbose "Repository [$Owner/$Name] deleted."
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
