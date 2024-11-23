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
        Write-Verbose "[$commandName] - Start"
        Write-Host 'Begin'
    }

    process {
        try {
            Write-Host 'Process'
            if ($PSCmdlet.ShouldProcess('Target', 'Operation')) {
                Write-Host "Name: $Name"
                Write-Host "Value: $Value"
            }
        } catch {
            Write-Host "Error: $_"
        } finally {
            Write-Host 'Finally'
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }

    clean {
        Write-Host 'Clean'
    }
}
