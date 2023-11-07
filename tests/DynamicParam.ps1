function Test-DynParam {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('A', 'B', 'C')]
        [string]$Param1
    )

    DynamicParam {
        $ParamDictionary = New-ParamDictionary

        $dynParam2 = @{
            Name            = 'Param2'
            Type            = [string]
            ValidateSet     = Get-Process | Select-Object -ExpandProperty Name
            ParamDictionary = $ParamDictionary
        }
        New-DynamicParam @dynParam2

        $dynParam3 = @{
            Name            = 'Param3'
            Type            = [string]
            ValidateSet     = Get-ChildItem -Path C:\ | Select-Object -ExpandProperty Name
            ParamDictionary = $ParamDictionary
        }
        New-DynamicParam @dynParam3

        return $ParamDictionary
    }

    process {
        $Param1 = $PSBoundParameters['Param1']
        $Param2 = $PSBoundParameters['Param2']
        $Param3 = $PSBoundParameters['Param3']

        Write-Host "Param1: $Param1"
        Write-Host "Param2: $Param2"
        Write-Host "Param3: $Param3"
    }
}

Test-DynParam -Param1 A -Param3 PerfLogs
