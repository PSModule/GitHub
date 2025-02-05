function Set-GitHubOutput {
    <#
    .SYNOPSIS
    Sets the GitHub output for a given key and value.

    .DESCRIPTION
    This function appends key-value pairs to the GitHub Actions output file specified by $env:GITHUB_OUTPUT.
    It handles two scenarios:
    - Normal shell execution: Appends the key-value pair directly.
    - GitHub composite action via [GitHub-Script](https://github.com/PSModule/GitHub-Script):
        Accumulates key-value pairs under the 'result' key as a JSON object.

    .EXAMPLE
    Set-GitHubOutput -Name 'ID' -Value '123123123'

    Sets the output variable 'ID' to '123123123' in the GitHub Actions output file.

    .EXAMPLE
    Set-GitHubOutput -Name 'result' -Value @{
        ID   = '123123123'
        name = 'test'
    }
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the output variable to set.
        [Parameter(Mandatory)]
        [string] $Name,

        # The value of the output variable to set.
        [Parameter(Mandatory)]
        [object] $Value,

        # The path to the GitHub output file.
        [Parameter()]
        [string] $Path = $env:GITHUB_OUTPUT
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if (-not (Test-Path -Path $Path)) {
            throw "File not found: $Path"
        }

        $outputs = Get-GitHubOutput -Path $Path -AsHashtable

        if ([string]::IsNullOrEmpty($env:GITHUB_ACTION)) {
            Write-Warning 'Cannot create output as the step has no ID.'
        }

        switch -Regex ($value.GetType().Name) {
            'SecureString' {
                $Value = $Value | ConvertFrom-SecureString -AsPlainText
                Add-Mask -Value $Value
            }
            'Hashtable|PSCustomObject' {
                Write-Debug 'Converting value to JSON:'
                $Value = $Value | ConvertTo-Json -Compress -Depth 100
                Write-Debug $value
            }
            default {}
        }

        Write-Verbose "Output: [$Name] = [$Value]"

        # If the script is running in a GitHub composite action, accumulate the output under the 'result' key,
        # else append the key-value pair directly.
        if ($env:PSMODULE_GITHUB_SCRIPT) {
            Write-Debug "[$stackPath] - Running in GitHub-Script composite action"
            if (-not $outputs.ContainsKey('result')) {
                $outputs['result'] = @{}
            }
            $outputs['result'][$Name] = $Value
        } else {
            Write-Debug "[$stackPath] - Running in a custom action"
            $outputs[$Name] = $Value
        }

        if ($PSCmdlet.ShouldProcess('GitHub Output', 'Set')) {
            $outputs | ConvertTo-GitHubOutput | Set-Content -Path $Path
        }

    }

    end {
        if ($env:PSMODULE_GITHUB_SCRIPT) {
            Write-Verbose "Output: [$Name] avaiable as '`${{ fromJson(steps.$env:GITHUB_ACTION.outputs.result).$Name }}'"
        } else {
            Write-Verbose "Output: [$Name] avaiable as '`${{ steps.$env:GITHUB_ACTION.outputs.$Name }}'"
        }
        Write-Debug "[$stackPath] - End"
    }
}
