function Set-GitHubEnvironmentVariable {
    <#
        .SYNOPSIS
        Setting an environment variable

        .DESCRIPTION
        Set a GitHub environment variable

        .EXAMPLE
        ```powershell
        Set-GitHubEnv -Name 'MyVariable' -Value 'MyValue'
        ```

        .NOTES
        [Setting an environment variable](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#setting-an-environment-variable)

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Set-GitHubEnvironmentVariable
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '', Scope = 'Function',
        Justification = 'Long doc links'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function',
        Justification = 'Does not change system state significantly'
    )]
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # Name of the variable
        [Parameter(Mandatory)]
        [string] $Name,

        # Value of the variable to set. Can be null.
        [Parameter()]
        [AllowNull()]
        [string] $Value
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        Write-Verbose "Env: [$Name] = [$Value]"

        $guid = [guid]::NewGuid().Guid
        $content = @"
$Name<<$guid
$Value
$guid
"@
        $content | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
