filter Set-GitHubReleaseAsset {
    <#
        .SYNOPSIS
        Update a release asset

        .DESCRIPTION
        Users with push access to the repository can edit a release asset.

        .EXAMPLE
        Set-GitHubReleaseAsset -Owner 'octocat' -Repo 'hello-world' -ID '1234567' -Name 'new_asset_name' -Label 'new_asset_label'

        Updates the release asset with the ID '1234567' for the repository 'octocat/hello-world' with the new name 'new_asset_name' and
        label 'new_asset_label'.

        .NOTES
        https://docs.github.com/rest/releases/assets#update-a-release-asset

    #>
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The unique identifier of the asset.
        [Parameter(Mandatory)]
        [Alias('asset_id')]
        [string] $ID,

        #The file name of the asset.
        [Parameter()]
        [string] $Name,

        # An alternate short description of the asset. Used in place of the filename.
        [Parameter()]
        [string] $Label,

        # State of the release asset.
        [Parameter()]
        [ValidateSet('uploaded', 'open')]
        [string] $State

    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntries -Hashtable $body -RemoveNames 'Owner', 'Repo', 'ID'

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/releases/assets/$ID"
        Method      = 'PATCH'
        Body        = $requestBody
    }

    (Invoke-GitHubAPI @inputObject).Response

}
