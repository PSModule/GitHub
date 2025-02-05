function Get-GitBranchFileContent {
    [CmdletBinding()]
    param(
        # The path of the file in the repository
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string] $Path,

        # The branch to get file content from
        [Parameter()]
        [string] $Branch = 'main'
    )

    $filePaths = git ls-tree -r $Branch --name-only $Path
    $content = @()
    foreach ($filePath in $filePaths) {
        # Retrieve file content from the first reference
        $tmp = git show "$Branch`:$filePath"
        $tmp = $tmp -replace '∩╗┐'
        $content += $tmp
    }

    return $content
}

$main = Get-GitBranchFileContent -Path 'C:\Repos\GitHub\PSModule\Module\GitHub\src' -Branch 'main'
$head = Get-GitBranchFileContent -Path 'C:\Repos\GitHub\PSModule\Module\GitHub\src' -Branch 'HEAD'

$main | Out-File -FilePath 'C:\Repos\GitHub\PSModule\Module\GitHub\src\main.txt'
$head | Out-File -FilePath 'C:\Repos\GitHub\PSModule\Module\GitHub\src\head.txt'



