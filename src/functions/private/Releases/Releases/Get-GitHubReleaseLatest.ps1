filter Get-GitHubReleaseLatest {
    <#
        .SYNOPSIS
        Get the latest release

        .DESCRIPTION
        View the latest published full release for the repository.
        The latest release is the most recent non-prerelease, non-draft release, sorted by the `created_at` attribute.
        The `created_at` attribute is the date of the commit used for the release, and not the date when the release was drafted or published.

        .EXAMPLE
        Get-GitHubReleaseLatest -Owner 'octocat' -Repo 'hello-world'

        Gets the latest releases for the repository 'hello-world' owned by 'octocat'.

        .NOTES
        https://docs.github.com/rest/releases/releases#get-the-latest-release

    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repo,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo: [$Repo]"
    }

    process {
        try {
            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/releases/latest"
                Method      = 'GET'
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
