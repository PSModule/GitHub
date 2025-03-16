filter Get-GitHubEnvironmentList {
    <#
        .SYNOPSIS
        Lists the environments for a repository.

        .DESCRIPTION
        Lists the environments available in a specified GitHub repository.
        Anyone with read access to the repository can use this endpoint.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope
        to use this endpoint with a private repository.

        .EXAMPLE
        Get-GitHubEnvironmentList -Owner 'octocat' -Repository 'Hello-World' -Context $GitHubContext

        Output:
        ```powershell
        Name         : production
        Protection   : @{required_reviewers=System.Object[]}
        ```

        Retrieves the list of environments for the 'Hello-World' repository owned by 'octocat'.

        .OUTPUTS
        PSCustomObject

        .NOTES
        Contains details of each environment in the repository, including its name and protection settings.

        .LINK
        [List environments](https://docs.github.com/rest/deployments/environments#list-environments)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Repository,

        # The maximum number of environments to return per request.
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            per_page = $PerPage
        }

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/environments"
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
