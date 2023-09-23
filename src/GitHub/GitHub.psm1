[Cmdletbinding()]
param()

$scriptName = $MyInvocation.MyCommand.Name
Write-Verbose "[$scriptName] Importing subcomponents"

#region - Data import
Write-Verbose "[$scriptName] - [data] - Processing folder"
$dataFolder = (Join-Path $PSScriptRoot 'data')
Write-Verbose "[$scriptName] - [data] - [$dataFolder]"
Get-ChildItem -Path "$dataFolder" -Recurse -File -Force | ForEach-Object {
    Write-Verbose "[$scriptName] - [data] - [$($_.Name)]"
    New-Variable -Name $_.BaseName -Value (Import-PowerShellDataFile -Path $_.FullName) -Force
    Write-Verbose "[$scriptName] - [data] - [$($_.Name)] - Done"
}
Write-Verbose "[$scriptName] - [data] - Done"
#endregion - Data import

# Import everything in these folders
#region - Script import
$folders = 'init', 'classes', 'private', 'public'
foreach ($folder in $folders) {
    Write-Verbose "[$scriptName] - [$folder] - Processing folder"
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $folderPath) {
        $files = Get-ChildItem -Path $folderPath -Include '*.ps1', '*.psm1' -Recurse | Sort-Object -Property FullName
        foreach ($file in $files) {
            Write-Verbose "[$scriptName] - [$folder] - [$($file.Name)] - Importing"
            Import-Module $file -Verbose:$false
            Write-Verbose "[$scriptName] - [$folder] - [$($file.Name)] - Done"
        }
    }
    Write-Verbose "[$scriptName] - [$folder] - Done"
}
#endregion - Script import

#region - Root import
Write-Verbose "[$scriptName] - [Root] - Processing folder"
Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1' | ForEach-Object {
    Write-Verbose "[$scriptName] - [Root] - [$($_.Name)] - Importing"
    Import-Module $_ -Verbose:$false
    Write-Verbose "[$scriptName] - [Root] - [$($_.Name)] - Done"
}
Write-Verbose "[$scriptName] - [Root] - Done"
#endregion - Root import

$foldersToProcess = Get-ChildItem -Path $PSScriptRoot -Directory | Where-Object -Property Name -In $folders
$moduleFiles = $foldersToProcess | Get-ChildItem -Include '*.ps1' -Recurse -File -Force
$functions = $moduleFiles.BaseName
$Param = @{
    Function = $functions
    Variable = ''
    Cmdlet   = ''
    Alias    = '*'
}

Write-Verbose 'Exporting module members'

Export-ModuleMember @Param
