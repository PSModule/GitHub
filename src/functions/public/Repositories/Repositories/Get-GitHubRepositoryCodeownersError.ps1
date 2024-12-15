filter Get-GitHubRepositoryCodeownersError {
    <#
        .SYNOPSIS
        List CODEOWNERS errors

        .DESCRIPTION
        List any syntax errors that are detected in the CODEOWNERS file.

        For more information about the correct CODEOWNERS syntax,
        see "[About code owners](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)."

        .EXAMPLE
        Get-GitHubRepositoryCodeownersError -Owner 'PSModule' -Repo 'GitHub'

        Gets the CODEOWNERS errors for the repository.

        .NOTES
        [List CODEOWNERS errors](https://docs.github.com/rest/repos/repos#list-codeowners-errors)

    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # A branch, tag or commit name used to determine which version of the CODEOWNERS file to use.
        # Default: the repository's default branch (e.g. main)
        [Parameter()]
        [string] $Ref,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
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
                ref = $Ref
            } | Remove-HashtableEntry -NullOrEmptyValues

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/codeowners/errors"
                Method      = 'GET'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
