[PSCustomObject]@{
    RepositoryPath               = [System.IO.Path]::GetFullPath("$PSScriptRoot/../../../..")
    InstructionsPath             = [System.IO.Path]::GetFullPath("$PSScriptRoot/../../../instructions")
    OrganizationInstructionsPath = [System.IO.Path]::GetFullPath("$PSScriptRoot/../../../instructions/organization")
    RepositoryInstructionsPath   = [System.IO.Path]::GetFullPath("$PSScriptRoot/../../../instructions/Repository")
} | Format-List
