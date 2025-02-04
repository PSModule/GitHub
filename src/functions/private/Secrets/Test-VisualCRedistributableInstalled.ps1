function Test-VisualCRedistributableInstalled {
    <#
    .SYNOPSIS
        Determine if a version of the VC++ Redistributable is installed and greater than or equal to the specified version.

    .PARAMETER Version
        The Minimum version required.

    .OUTPUTS
        [bool]
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [Version]$Version
    )

    process {
        $result = $false
        if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
            $key = 'HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\X64'
            if (Test-Path -Path $key) {
                $installedVersion = (Get-ItemProperty -Path $key).Version
                $result = [Version]($installedVersion.SubString(1,$installedVersion.Length-1)) -ge $Version
            }
        }
        $result
    }
}
