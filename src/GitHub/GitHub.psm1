[Cmdletbinding()]
param()

$scriptName = $MyInvocation.MyCommand.Name
Write-Verbose "[$scriptName] - Importing module"

#region - Importing data files
Write-Verbose "[$scriptName] - [data] - Processing folder"
$dataFolder = (Join-Path $PSScriptRoot 'data')
Write-Verbose "[$scriptName] - [data] - [$dataFolder]"
Get-ChildItem -Path "$dataFolder" -Recurse -Force -Include '*.psd1' | ForEach-Object {
    Write-Verbose "[$scriptName] - [data] - [$($_.Name)] - Importing data file"
    New-Variable -Name $_.BaseName -Value (Import-PowerShellDataFile -Path $_.FullName) -Force
    Write-Verbose "[$scriptName] - [data] - [$($_.Name)] - Done"
}
Write-Verbose "[$scriptName] - [data] - Done"
#endregion - Importing datas

#region - Importing script files
$folders = 'init', 'classes', 'private', 'public'
foreach ($folder in $folders) {
    Write-Verbose "[$scriptName] - [$folder] - Processing folder"
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $folderPath) {
        $files = Get-ChildItem -Path $folderPath -Include '*.ps1', '*.psm1' -Recurse | Sort-Object -Property FullName
        foreach ($file in $files) {
            Write-Verbose "[$scriptName] - [$folder] - [$($file.Name)] - Importing script file"
            Import-Module $file -Verbose:$false
            Write-Verbose "[$scriptName] - [$folder] - [$($file.Name)] - Done"
        }
    }
    Write-Verbose "[$scriptName] - [$folder] - Done"
}
#endregion - Importing script files

#region - Importing root script files
Write-Verbose "[$scriptName] - [PSModuleRoot] - Processing folder"
Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1' | ForEach-Object {
    Write-Verbose "[$scriptName] - [PSModuleRoot] - [$($_.Name)] - Importing root script files"
    Import-Module $_ -Verbose:$false
    Write-Verbose "[$scriptName] - [PSModuleRoot] - [$($_.Name)] - Done"
}
Write-Verbose "[$scriptName] - [Root] - Done"
#endregion - Importing root script files

#region Export module members
$foldersToProcess = Get-ChildItem -Path $PSScriptRoot -Directory | Where-Object -Property Name -In $folders
$moduleFiles = $foldersToProcess | Get-ChildItem -Include '*.ps1' -Recurse -File -Force
$functions = $moduleFiles.BaseName
$param = @{
    Function = $functions
    Variable = ''
    Cmdlet   = ''
    Alias    = '*'
}

Write-Verbose 'Exporting module members'

Export-ModuleMember @param
#endregion Export module members

Write-Verbose "[$scriptName] - Done"
