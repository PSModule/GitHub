filter Set-GitHubRepositoryTopic {
    <#
        .SYNOPSIS
        Replace all repository topics

        .DESCRIPTION
        Replace all repository topics

        .EXAMPLE
        Set-GitHubRepositoryTopic -Owner 'octocat' -Repo 'hello-world' -Names 'octocat', 'octo', 'octocat/hello-world'

        Replaces all topics for the repository 'octocat/hello-world' with the topics 'octocat', 'octo', 'octocat/hello-world'.

        .NOTES
        [Replace all repository topics](https://docs.github.com/rest/repos/repos#replace-all-repository-topics)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The number of results per page (max 100).
        [Parameter()]
        [Alias('Topics')]
        [string[]] $Names = @(),

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
                names = $Names | ForEach-Object { $_.ToLower() }
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/topics"
                Method      = 'PUT'
                Body        = $body
            }

            if ($PSCmdlet.ShouldProcess("topics for repo [$Owner/$Repo]", 'Set')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response.names
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
