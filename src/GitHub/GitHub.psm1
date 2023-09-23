[Cmdletbinding()]
param()

$scriptName = $MyInvocation.MyCommand.Name

Write-Verbose "[$scriptName] Importing subcomponents"

Join-Path $PSScriptRoot 'Data' | Get-ChildItem -Recurse -File -Force | ForEach-Object {
    Write-Verbose "[$scriptName] - [$PSScriptRoot] - [Data] - Done"
    New-Variable -Name $_.BaseName -Value (Import-PowerShellDataFile -Path $_.FullName) -Force
}

# Import everything in these folders
$folders = 'init', 'classes', 'private', 'public'
foreach ($folder in $folders) {
    Write-Verbose "[$scriptName] - Processing folder [$folder]"
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    Write-Verbose "[$scriptName] - [$folderPath]"
    if (Test-Path -Path $folderPath) {
        Write-Verbose "[$scriptName] - [$folderPath] - Getting all files"
        $files = Get-ChildItem -Path $folderPath -Include '*.ps1', '*.psm1' -Recurse
        foreach ($file in $files) {
            Write-Verbose "[$scriptName] - [$folderPath] - [$($file.Name)] - Importing"
            Import-Module $file
            Write-Verbose "[$scriptName] - [$folderPath] - [$($file.Name)] - Done"
        }
    }
}

$PSScriptRoot | Get-ChildItem -Path $folderPath -Include '*.ps1' | ForEach-Object {
    Write-Verbose "[$scriptName] - [$PSScriptRoot] - [$(_.Name)] - Done"
    Import-Module $_.FullName
}

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
