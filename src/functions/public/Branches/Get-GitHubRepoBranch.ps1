filter Get-GitHubRepoBranch {
    <#
        .SYNOPSIS
        List branches

        .DESCRIPTION
        Lists all branches from a repository

        .EXAMPLE
        Get-GitHubRepoBranch -Owner 'octocat' -Repo 'Hello-World'

        Gets all the branches from the 'Hello-World' repository owned by 'octocat'

        .NOTES
        [List branches](https://docs.github.com/rest/branches/branches#list-branches)
    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

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
        $inputObject = @{
            Method      = 'Get'
            APIEndpoint = "/repos/$Owner/$Repo/branches"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
