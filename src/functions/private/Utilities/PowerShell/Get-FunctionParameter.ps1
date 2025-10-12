function Get-FunctionParameter {
    <#
        .SYNOPSIS
        Get the parameters and their final value in a function.

        .DESCRIPTION
        This function retrieves the parameters and their final value in a function.
        If a parameter is provided, it will retrieve the provided value.
        If a parameter is not provided, it will attempt to retrieve the default value.

        .EXAMPLE
        ```pwsh
        Get-FunctionParameter
        ```

        This will return all the parameters and their final value in the current function.

        .EXAMPLE
        ```pwsh
        Get-FunctionParameter -IncludeCommonParameters
        ```

        This will return all the parameters and their final value in the current function, including common parameters.

        .EXAMPLE
        ```pwsh
        Get-FunctionParameter -Scope 2
        ```

        This will return all the parameters and their final value in the grandparent function.
    #>
    [OutputType([pscustomobject], [hashtable])]
    [CmdletBinding()]
    param(
        # Include common parameters in the output.
        [Parameter()]
        [switch] $IncludeCommonParameters,

        # The function to get the parameters for.
        # Default is the calling scope (0).
        # Scopes are based on nesting levels:
        # 0 - Current scope
        # 1 - Parent scope
        # 2 - Grandparent scope
        [Parameter()]
        [int] $Scope = 0,

        # Return the parameters as a hashtable.
        [Parameter()]
        [switch] $AsHashtable
    )

    $Scope++

    $commonParameters = @(
        'ProgressAction', 'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable',
        'OutVariable', 'OutBuffer', 'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable', 'WhatIf',
        'Confirm'
    )

    $InvocationInfo = (Get-Variable -Name MyInvocation -Scope $Scope -ErrorAction Stop).Value
    $boundParameters = $InvocationInfo.BoundParameters
    $allParameters = @{}
    $parameters = $InvocationInfo.MyCommand.Parameters

    foreach ($paramName in $parameters.Keys) {
        if (-not $IncludeCommonParameters -and $paramName -in $commonParameters) {
            continue
        }
        if ($boundParameters.ContainsKey($paramName)) {
            # Use the explicitly provided value
            $allParameters[$paramName] = $boundParameters[$paramName]
        } else {
            # Attempt to retrieve the default value by invoking it
            try {
                $defaultValue = (Get-Variable -Name $paramName -Scope $Scope -ErrorAction SilentlyContinue).Value
            } catch {
                $defaultValue = $null
            }
            $allParameters[$paramName] = $defaultValue
        }
    }

    if ($AsHashtable) {
        return $allParameters
    }

    [pscustomobject]$allParameters
}
