function Export-GitHubVariable {
    <#
        .SYNOPSIS
        Exports a GitHub variable to the local environment.

        .DESCRIPTION
        This function takes a GitHub variable and sets it as an environment variable.
        The variable can be exported to the Process, User, or Machine environment scope.

        By default, the variable is exported to the Process scope, meaning it will persist only for the current session.

        The function accepts pipeline input, allowing GitHub variables retrieved using `Get-GitHubVariable` to be exported seamlessly.

        .EXAMPLE
        Get-GitHubVariable -Owner 'octocat' -Repository 'Hello-World' -Environment 'staging' | Export-GitHubVariable

        Exports the variables retrieved from the GitHub API to the local environment.

        .INPUTS
        GitHubVariable

        .OUTPUTS
        void

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/Export-GitHubVariable
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # The name of the variable.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,

        # The value of the variable.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Value,

        # The target scope for the environment variable.
        [Parameter()]
        [System.EnvironmentVariableTarget] $Target = [System.EnvironmentVariableTarget]::Process
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        Write-Debug "$($_.Name) = $($_.Value)"
        [System.Environment]::SetEnvironmentVariable($Name, $Value, $Target)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
