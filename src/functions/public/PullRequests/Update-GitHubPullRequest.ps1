filter Update-GitHubPullRequest {
    <#
        .SYNOPSIS
        Update a pull request.

        .DESCRIPTION
        Updates a pull request in a repository. You can update the title, body, state (open/closed), base branch,
        and whether maintainers can modify the pull request. This is useful for automating pull request management,
        such as closing superseded pull requests or updating their descriptions.

        .EXAMPLE
        ```powershell
        Update-GitHubPullRequest -Owner 'octocat' -Repository 'Hello-World' -Number 1 -State 'closed'
        ```

        Closes pull request #1 in the repository.

        .EXAMPLE
        ```powershell
        Update-GitHubPullRequest -Owner 'octocat' -Repository 'Hello-World' -Number 1 -Title 'New title' -Body 'Updated description'
        ```

        Updates the title and body of pull request #1.

        .EXAMPLE
        ```powershell
        Get-GitHubPullRequest -Owner 'octocat' -Repository 'Hello-World' -Head 'octocat:old-feature' | Update-GitHubPullRequest -State 'closed'
        ```

        Closes all pull requests from the 'old-feature' branch using pipeline input.

        .INPUTS
        GitHubPullRequest

        .OUTPUTS
        GitHubPullRequest

        .LINK
        https://docs.github.com/rest/pulls/pulls#update-a-pull-request
    #>
    [OutputType([GitHubPullRequest])]
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The number that identifies the pull request.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $Number,

        # The title of the pull request.
        [Parameter()]
        [string] $Title,

        # The contents of the pull request body.
        [Parameter()]
        [string] $Body,

        # State of this Pull Request. Either 'open' or 'closed'.
        [Parameter()]
        [ValidateSet('open', 'closed')]
        [string] $State,

        # The name of the branch you want your changes pulled into. This should be an existing branch on the current repository.
        [Parameter()]
        [string] $Base,

        # Indicates whether maintainers can modify the pull request.
        [Parameter()]
        [System.Nullable[bool]] $MaintainerCanModify,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $params = @{
            Owner               = $Owner
            Repository          = $Repository
            Number              = $Number
            Title               = $Title
            Body                = $Body
            State               = $State
            Base                = $Base
            MaintainerCanModify = $MaintainerCanModify
            Context             = $Context
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues

        if ($DebugPreference -eq 'Continue') {
            Write-Debug "Updating pull request #$Number in $Owner/$Repository"
            [pscustomobject]$params | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        }

        Update-GitHubPullRequestByNumber @params
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
