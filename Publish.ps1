[CmdletBinding()]
param (
    [Parameter()]
    [string] $APIKKey
)

Get-ChildItem -Path .\src | ForEach-Object {
    Publish-Module -Path $_.FullName -NuGetApiKey $using:APIKKey -Force -Verbose
}
