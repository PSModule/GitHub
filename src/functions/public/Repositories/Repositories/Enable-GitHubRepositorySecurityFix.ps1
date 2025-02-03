filter Enable-GitHubRepositorySecurityFix {
    <#
        .SYNOPSIS
        Enable automated security fixes

        .DESCRIPTION
        Enables automated security fixes for a repository. The authenticated user must have admin access to the repository.
        For more information, see
        "[Configuring automated security fixes](https://docs.github.com/articles/configuring-automated-security-fixes)".

        .EXAMPLE
        Enable-GitHubRepositorySecurityFix -Owner 'PSModule' -Repo 'GitHub'

        Enables automated security fixes for the repository.

        .NOTES
        [Enable automated security fixes](https://docs.github.com/rest/repos/repos#enable-automated-security-fixes)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [Alias('Enable-GitHubRepositorySecurityFixes')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

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
            Method      = 'Put'
            APIEndpoint = "/repos/$Owner/$Repo/automated-security-fixes"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Security Fixes for [$Owner/$Repo]", 'Enable')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
