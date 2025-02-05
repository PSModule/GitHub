filter New-GitHubRepositoryTagProtection {
    <#
        .SYNOPSIS
        Create a tag protection state for a repository

        .DESCRIPTION
        This creates a tag protection state for a repository.
        This endpoint is only available to repository administrators.

        .EXAMPLE
        New-GitHubRepositoryTagProtection -Owner 'octocat' -Repository 'hello-world' -Pattern 'v1.*'

        Creates a tag protection state for the 'hello-world' repository with the pattern 'v1.*'.

        .NOTES
        [Create a tag protection state for a repository](https://docs.github.com/rest/repos/tags#create-a-tag-protection-state-for-a-repository)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # An optional glob pattern to match against when enforcing tag protection.
        [Parameter(Mandatory)]
        [string] $Pattern,

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
    }

    process {
        $body = @{
            pattern = $Pattern
        }

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = "/repos/$Owner/$Repository/tags/protection"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("tag protection state on pattern [$Pattern] for repository [$Owner/$Repository]", 'Create')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
