###
### List Top-Level Folders and Subdirectories in a GitHub Repository
###

# Define repository owner and name
$owner = 'github'
$Repository = 'rest-api-description'

# GitHub API URL for root contents
$rootUrl = "https://api.github.com/repos/$owner/$Repository/contents"

# Invoke the REST API to get root contents (add User-Agent header if needed)
$rootContents = Invoke-RestMethod -Uri $rootUrl -Headers @{ 'Accept' = 'application/vnd.github.v3+json' }
$rootContents | Format-Table -AutoSize

$rootContents | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.name
        Size = $_.size
        Type = $_.type
    }
} | Sort-Object Type, Name | Format-Table

# Filter for directories in the root (type equals "dir")
$topLevelFolders = $rootContents | Where-Object { $_.type -eq 'dir' } | Select-Object -ExpandProperty name

# Output the top-level folder names
$topLevelFolders


###
### List Subdirectories for Each Top Folder:
###

foreach ($folder in $topLevelFolders) {
    Write-Host "`nSubfolders in '$folder':"
    # Construct URL for the folder's contents
    $folderUrl = "https://api.github.com/repos/$owner/$Repository/contents/$folder"
    $folderContents = Invoke-RestMethod -Uri $folderUrl -Headers @{ 'Accept' = 'application/vnd.github.v3+json' }

    # Filter for subdirectories (type "dir") within this folder
    $subDirs = $folderContents | Where-Object { $_.type -eq 'dir' } | Select-Object -ExpandProperty name

    # Print each subfolder name
    $subDirs | ForEach-Object { Write-Host "- $_" }
}



# (Optional) Get entire tree recursively - may return a lot of data for large repos
$branch = 'main'  # or specify default branch/commit SHA
$treeUrl = "https://api.github.com/repos/$owner/$Repository/git/trees/$branch`?recursive=1"
$treeData = Invoke-RestMethod -Uri $treeUrl -Headers @{ 'Accept' = 'application/vnd.github.v3+json' }

# $treeData.tree is a list of all paths in the repository (each with type "blob" for file or "tree" for folder).
# We can filter this list for type "tree" to get directories.
$allDirs = $treeData.tree | Where-Object { $_.type -eq 'tree' } | Select-Object -ExpandProperty path



function Get-GitHubAPIDescription {
    <#
        .SYNOPSIS
        Retrieves the GitHub REST API description from the GitHub REST API description repository.

        .DESCRIPTION
        Retrieves the GitHub REST API description from the GitHub REST API description repository.
        The API description is used to generate the GitHub REST API functions.

        .EXAMPLE
        Get-GitHubAPIDescription
    #>

    # GitHub REST API description repository
    $APIDocURI = 'https://raw.githubusercontent.com/github/rest-api-description/main'
    $Bundled = '/descriptions/api.github.com/api.github.com.json'
    $APIDocURI = $APIDocURI + $Bundled
    $response = Invoke-RestMethod -Uri $APIDocURI -Method Get

    return $response
}
