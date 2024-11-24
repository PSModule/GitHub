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
        Write-Verbose 'Begin'
    }

    process {
        try {
            Write-Verbose 'Process'
            if ($PSCmdlet.ShouldProcess('Target', 'Operation')) {
                Write-Verbose "Name: $Name"
                Write-Verbose "Value: $Value"
            }
        } catch {
            Write-Verbose "Error: $_"
        } finally {
            Write-Verbose 'Finally'
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }

    clean {
        Write-Verbose 'Clean'
    }
}
