filter Add-GitHubMask {
    <#
        .SYNOPSIS
        Masks a value in a log

        .DESCRIPTION
        Masking a value prevents a string or variable from being printed in the log. Each masked word separated by whitespace is
        replaced with the * character. You can use an environment variable or string for the mask's value. When you mask a value,
        it is treated as a secret and will be redacted on the runner. For example, after you mask a value, you won't be able to
        set that value as an output.

        .EXAMPLE
        Add-Mask $SecretValue

        Masks the value of $SecretValue so that its printed like ***.

        .EXAMPLE
        $SecretValue1, $SecretValue2 | Mask

        Masks the value of $SecretValue1 and $SecretValue2 so that its printed like ***, using the pipeline

        .NOTES
        [Masking a value in a log](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#masking-a-value-in-a-log)
    #>
    [Alias('Mask', 'Add-Mask')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '', Scope = 'Function',
        Justification = 'Long documentation URL'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function',
        Justification = 'Does not change state'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '', Scope = 'Function',
        Justification = 'Intended for logging in Github Runners which does support Write-Host'
    )]
    [CmdletBinding()]
    param(
        # The value to mask
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [AllowNull()]
        [string[]] $Value
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        foreach ($item in $Value) {
            Write-Host "::add-mask::$item"
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
