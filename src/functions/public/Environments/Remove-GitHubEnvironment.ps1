filter Remove-GitHubEnvironment {
    <#
        .SYNOPSIS
        Deletes an environment from a repository.

        .DESCRIPTION
        Removes a specified environment from a given repository on GitHub. This action is irreversible.
        The function supports ShouldProcess for confirmation before execution.

        .EXAMPLE
        Remove-GitHubEnvironment -Owner 'PSModule' -Repository 'GitHub' -Name 'Production'

        Deletes the 'Production' environment from the 'PSModule/GitHub' repository.

        .LINK
        https://psmodule.io/GitHub/Functions/Environments/Remove-GitHubEnvironment/

        .NOTES
        [Delete environments](https://docs.github.com/rest/deployments/environments?#delete-an-environment)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the organization.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the environment to delete.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
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
        $encodedName = [System.Uri]::EscapeDataString($Name)
        $inputObject = @{
            Method  = 'DELETE'
            Uri     = $Context.ApiBaseUri + "/repos/$Owner/$Repository/environments/$encodedName"
            Context = $Context
        }

        if ($PSCmdlet.ShouldProcess("Environment [$Owner/$Repository/$Name]", 'Delete')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
