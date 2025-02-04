function Test-IsCodespace {
    [CmdletBinding()]
    [OutputType([bool])]
    param ()
    -not ($null -eq $env:CODESPACES)
}
