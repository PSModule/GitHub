[PSCustomObject]@{
    RepositoryPath             = [System.IO.Path]::GetFullPath("$PSScriptRoot/../../../..")
    InstructionsPath           = [System.IO.Path]::GetFullPath("$PSScriptRoot/../../../instructions")
    FrameworkInstructionsPath  = [System.IO.Path]::GetFullPath("$PSScriptRoot/../../../instructions/framework")
    RepositoryInstructionsPath = [System.IO.Path]::GetFullPath("$PSScriptRoot/../../../instructions/repo")
} | Format-List
