filter Get-GitHubRepositoryLicense {
    <#
        .SYNOPSIS
        Get the license for a repository

        .DESCRIPTION
        This method returns the contents of the repository's license file, if one is detected.

        Similar to [Get repository content](https://docs.github.com/rest/repos/contents#get-repository-content), this method also supports
        [custom media types](https://docs.github.com/rest/overview/media-types) for retrieving the raw license content or rendered license HTML.

        .EXAMPLE
        Get-GitHubRepositoryLicense -Owner 'octocat' -Repo 'Hello-World'

        Get the license for the Hello-World repository from the octocat account.

        .NOTES
        https://docs.github.com/rest/licenses/licenses#get-the-license-for-a-repository

    #>
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo)
    )

    Process {
        $inputObject = @{
            APIEndpoint = "/repos/$Owner/$Repo/license"
            Accept      = 'application/vnd.github+json'
            Method      = 'GET'
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $Response = $_.Response
            $rawContent =  [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Response.content))
            $Response | Add-Member -NotePropertyName 'raw_content' -NotePropertyValue $rawContent -Force
            $Response
        }
    }
}
