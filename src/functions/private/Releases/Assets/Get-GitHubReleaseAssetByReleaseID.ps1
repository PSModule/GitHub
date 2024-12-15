filter Get-GitHubReleaseAssetByReleaseID {
    <#
        .SYNOPSIS
        List release assets

        .DESCRIPTION
        List release assets

        .EXAMPLE
        Get-GitHubReleaseAssetByReleaseID -Owner 'octocat' -Repo 'hello-world' -ID '1234567'

        Gets the release assets for the release with the ID '1234567' for the repository 'octocat/hello-world'.

        .NOTES
        https://docs.github.com/rest/releases/assets#list-release-assets

    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repo,

        # The unique identifier of the release.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ID'
        )]
        [Alias('release_id')]
        [string] $ID,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner : [$($Context.Owner)]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo : [$($Context.Repo)]"
    }

    process {
        try {
            $body = @{
                per_page = $PerPage
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/releases/$ID/assets"
                Method      = 'GET'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }
    end {
        Write-Debug "[$stackPath] - End"
    }
}
