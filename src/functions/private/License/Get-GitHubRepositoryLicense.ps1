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
        [Get the license for a repository](https://docs.github.com/rest/licenses/licenses#get-the-license-for-a-repository)

    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The type of data to return. Can be either 'raw' or 'html'.
        [Parameter()]
        [ValidateSet('raw', 'html')]
        [string] $Type = 'raw',

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

        $contentType = switch ($Type) {
            'raw' { 'application/vnd.github.raw+json' }
            'html' { 'application/vnd.github.html+json' }
        }
    }

    process {
        try {
            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/license"
                ContentType = $contentType
                Method      = 'GET'
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                $Response = $_.Response
                $rawContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Response.content))
                $Response | Add-Member -NotePropertyName 'raw_content' -NotePropertyValue $rawContent -Force
                $Response
            }
        } catch {
            throw $_
        }
    }
    end {
        Write-Debug "[$stackPath] - End"
    }
}
