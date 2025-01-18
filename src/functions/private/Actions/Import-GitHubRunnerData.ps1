function Import-GitHubRunnerData {
    <#
        .SYNOPSIS
        Import data of the runner of the workflow

        .DESCRIPTION
        Import data of the runner of the workflow

        .EXAMPLE
        Import-GitHubRunnerData
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Just setting a value in a variable.'
    )]
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param()

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {
            $script:GitHub.Runner = [pscustomobject]@{
                Name        = $env:RUNNER_NAME
                OS          = $env:RUNNER_OS
                Arch        = $env:RUNNER_ARCH
                Environment = $env:RUNNER_ENVIRONMENT
                Temp        = $env:RUNNER_TEMP
                Perflog     = $env:RUNNER_PERFLOG
                ToolCache   = $env:RUNNER_TOOL_CACHE
                TrackingID  = $env:RUNNER_TRACKING_ID
                Workspace   = $env:RUNNER_WORKSPACE
                Processors  = [System.Environment]::ProcessorCount
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
