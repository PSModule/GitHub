filter Get-GitHubReleaseByTagName {
    <#
        .SYNOPSIS
        Get a release by tag name

        .DESCRIPTION
        Get a published release with the specified tag.

        .EXAMPLE
        Get-GitHubReleaseByTagName -Owner 'octocat' -Repo 'hello-world' -Tag 'v1.0.0'

        Gets the release with the tag 'v1.0.0' for the repository 'hello-world' owned by 'octocat'.

        .NOTES
        https://docs.github.com/rest/releases/releases#get-a-release-by-tag-name

    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repo,

        # The name of the tag to get a release from.
        [Parameter(Mandatory)]
        [Alias('tag_name')]
        [string] $Tag,

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
                APIEndpoint = "/repos/$Owner/$Repo/releases/tags/$Tag"
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
