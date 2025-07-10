filter Assert-GitHubContext {
    <#
        .SYNOPSIS
        Check if the context meets the requirements for the command.

        .DESCRIPTION
        This function checks if the context meets the requirements for the command.
        If the context does not meet the requirements, an error is thrown.

        .EXAMPLE
        Assert-GitHubContext -Context 'github.com/Octocat' -AuthType 'App'
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # The context to run the command in.
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [object] $Context,

        # The required authtypes for the command.
        [Parameter(Mandatory)]
        [string[]] $AuthType

        # TODO: Implement permission check
        # # The required permission for the command.
        # [Parameter()]
        # [string] $Permission
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $command = (Get-PSCallStack)[1].Command
        Write-Verbose "Context: $Context"
        Write-Verbose "AuthType: $AuthType"

        if (-not $Context) {
            if ('Anonymous' -in $AuthType) {
                return
            }
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    [System.Exception]::new("Please provide a valid context or log in using 'Connect-GitHub'."),
                    'InvalidContext',
                    [System.Management.Automation.ErrorCategory]::InvalidArgument,
                    $Context
                )
            )
        }
        if ($Context -eq 'Anonymous' -and $AuthType -contains 'Anonymous') { return }
        if ($Context.AuthType -in $AuthType) { return }

        $errorText = "The context '$($Context.Name)' is of type [$($Context.AuthType)] which does not match the required" +
        "types [$($AuthType -join ', ')] for [$command]."
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                [System.Exception]::new($errorText),
                'InvalidContextAuthType',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $Context
            )
        )
        # TODO: Implement permission check
        # if ($Context.AuthType -in 'IAT' -and $Context.Permission -notin $Permission) {
        #     throw "The context '$($Context.Name)' does not match the required Permission [$Permission] for [$command]."
        # }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
