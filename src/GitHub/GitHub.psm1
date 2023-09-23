[Cmdletbinding()]
param()

$sciptName = $MyInvocation.MyCommand.Name

Write-Verbose "[$sciptName] Importing subcomponents"
$folders = 'classes', 'private', 'public'
# Import everything in these folders
foreach ($folder in $folders) {
    Write-Verbose "[$sciptName] - Processing folder [$folder]"
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    Write-Verbose "[$sciptName] - [$folderPath]"
    if (Test-Path -Path $folderPath) {
        Write-Verbose "[$sciptName] - [$folderPath] - Getting all files"
        $files = $null
        $files = Get-ChildItem -Path $folderPath -Include '*.ps1', '*.psm1' -Recurse
        # dot source each file
        foreach ($file in $files) {
            Write-Verbose "[$sciptName] - [$folderPath] - [$($file.Name)] - Importing"
            Import-Module $file
            Write-Verbose "[$sciptName] - [$folderPath] - [$($file.Name)] - Done"
        }
    }
}

$foldersToProcess = Get-ChildItem -Path $PSScriptRoot -Directory | Where-Object -Property Name -In $folders
$moduleFiles = $foldersToProcess | Get-ChildItem -Include '*.ps1' -Recurse -File -Force
$functions = $moduleFiles.BaseName
$Param = @{
    Function = $functions
    Variable = '*'
    Cmdlet   = '*'
    Alias    = '*'
}

Write-Verbose 'Exporting module members'

Export-ModuleMember @Param
