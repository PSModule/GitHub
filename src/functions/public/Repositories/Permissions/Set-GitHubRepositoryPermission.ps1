filter Set-GitHubRepositoryPermission {
    <#
        .SYNOPSIS
        Set the permission level for a team on a repository

        .DESCRIPTION

        .EXAMPLE

        .INPUTS
        GitHubRepository

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Set-GitHubRepositoryPermission/

        .NOTES
        [Add or update team repository permissions](https://docs.github.com/rest/teams/teams#add-or-update-team-repository-permissions)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,

        # The slug of the team to add or update repository permissions for.
        [Parameter(Mandatory)]
        [Alias('Slug', 'TeamSlug')]
        [string] $Team,

        # The owner of the team. If not specified, the owner will default to the value of -Owner.
        [Parameter()]
        [string] $TeamOwner,

        # The permission to grant the team on this repository. We accept the following permissions to be set:
        # pull, triage, push, maintain, admin and you can also specify a custom repository role name, if the
        # owning organization has defined any. If you want to remove the permissions specify 'None'.
        [Parameter(Mandatory)]
        [string] $Permission,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        $TeamOwner = [string]::IsNullOrEmpty($TeamOwner) ? $Owner : $TeamOwner
    }

    process {
        if ($Permission -eq 'None') {
            return Remove-GitHubRepositoryPermission -Owner $Owner -Name $Name -Team $Team -TeamOwner $TeamOwner -Context $Context
        }

        $body = @{
            permission = $Permission
        }

        $inputObject = @{
            Method      = 'PUT'
            APIEndpoint = "/orgs/$TeamOwner/teams/$Team/repos/$Owner/$Name"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Team [$TeamOwner/$Team] repository permission [$Permission] on [$Owner/$Name]", "Set")) {
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
