filter Get-GitHubRepositoryLanguage {
    <#
        .SYNOPSIS
        List repository languages

        .DESCRIPTION
        Lists languages for the specified repository. The value shown for each language is the number of
        bytes of code written in that language.

        .EXAMPLE
        ```powershell
        Get-GitHubRepositoryLanguage -Owner 'octocat' -Name 'hello-world'
        ```

        Gets the languages for the 'hello-world' repository owned by 'octocat'.

        .NOTES
        [List repository languages](https://docs.github.com/rest/repos/repos#list-repository-languages)

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Repositories/Get-GitHubRepositoryLanguage
    #>
    [CmdletBinding()]
    [Alias('Get-GitHubRepositoryLanguages')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Name,

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
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Name/languages"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
