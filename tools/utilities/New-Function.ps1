function New-Function {
    <#
        .SYNOPSIS
        Short description

        .DESCRIPTION
        Long description

        .EXAMPLE
        An example

        .NOTES
        General notes
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # This parameter is mandatory
        [Parameter(Mandatory)]
        [string]$Name,

        # This parameter is mandatory
        [Parameter(Mandatory)]
        [string]$Value
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        Write-Debug 'Begin'
    }

    process {
        try {
            Write-Debug 'Process'
            if ($PSCmdlet.ShouldProcess('Target', 'Operation')) {
                Write-Debug "Name: $Name"
                Write-Debug "Value: $Value"
            }
        } catch {
            Write-Debug "Error: $_"
        } finally {
            Write-Debug 'Finally'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }

    clean {
        Write-Debug 'Clean'
    }
}
