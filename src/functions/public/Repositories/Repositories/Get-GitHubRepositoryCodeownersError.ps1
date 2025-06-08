filter Get-GitHubRepositoryCodeownersError {
    <#
        .SYNOPSIS
        List CODEOWNERS errors

        .DESCRIPTION
        List any syntax errors that are detected in the CODEOWNERS file.

        For more information about the correct CODEOWNERS syntax,
        see "[About code owners](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)."

        .EXAMPLE
        Get-GitHubRepositoryCodeownersError -Owner 'PSModule' -Name 'GitHub'

        Gets the CODEOWNERS errors for the repository.

        .NOTES
        [List CODEOWNERS errors](https://docs.github.com/rest/repos/repos#list-codeowners-errors)

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Repositories/Get-GitHubRepositoryCodeownersError
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Name,

        # A branch, tag or commit name used to determine which version of the CODEOWNERS file to use.
        # Default: the repository's default branch (e.g. main)
        [Parameter()]
        [string] $Ref,

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
        $body = @{
            ref = $Ref
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Name/codeowners/errors"
            Body        = $body
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
