filter Get-GitHubRepositoryCustomProperty {
    <#
        .SYNOPSIS
        Get all custom property values for a repository

        .DESCRIPTION
        Gets all custom property values that are set for a repository.
        Users with read access to the repository can use this endpoint.

        .EXAMPLE
        Get-GitHubRepositoryCustomProperty -Owner 'octocat' -Repo 'hello-world'

        Gets all custom property values that are set for the 'hello-world' repository.

        .NOTES
        [Get all custom property values for a repository](https://docs.github.com/rest/repos/custom-properties#get-all-custom-property-values-for-a-repository)
    #>
    #SkipTest:FunctionTest:Will add a test for this function in a future PR
    [Alias('Get-GitHubRepositoryCustomProperties')]
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [OutputType([pscustomobject])]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
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
                APIEndpoint = "/repos/$Owner/$Repo/properties/values"
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
