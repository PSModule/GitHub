function Get-GitHubEnvironmentType {
    <#
        .SYNOPSIS
        Determines the environment type for GitHub Actions.

        .DESCRIPTION
        Determines the environment type for GitHub Actions.

        .OUTPUTS
        System.String
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param()

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if ($script:IsGitHubActions) {
            Write-Debug 'Detected GitHub Actions environment.'
            return 'GHA'
        } elseif ($script:IsFunctionApp) {
            Write-Debug 'Detected Azure Functions environment.'
            return 'AFA'
        } else {
            Write-Debug 'Detected local environment.'
            return 'Local'
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
