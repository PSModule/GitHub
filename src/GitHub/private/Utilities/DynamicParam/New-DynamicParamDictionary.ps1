function New-DynamicParamDictionary {
    <#
        .SYNOPSIS
        Creates a new RuntimeDefinedParameterDictionary

        .DESCRIPTION
        Creates a new RuntimeDefinedParameterDictionary

        .EXAMPLE
        New-DynamicParamDictionary

        Returns a new RuntimeDefinedParameterDictionary
    #>
    [OutputType([System.Management.Automation.RuntimeDefinedParameterDictionary])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Function does not change state.'
    )]
    [CmdletBinding()]
    param()

    return [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
}
