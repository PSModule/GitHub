filter Get-GitHubRepositoryListByUser {
    <#
        .SYNOPSIS
        List repositories for a user

        .DESCRIPTION
        Lists public repositories for the specified user.
        Note: For GitHub AE, this endpoint will list internal repositories for the specified user.

        .EXAMPLE
        Get-GitHubRepositoryListByUser -Username 'octocat'

        Gets the repositories for the user 'octocat'.

        .EXAMPLE
        Get-GitHubRepositoryListByUser -Username 'octocat' -Type 'member'

        Gets the repositories of organizations where the user 'octocat' is a member.

        .EXAMPLE
        Get-GitHubRepositoryListByUser -Username 'octocat' -Sort 'created' -Direction 'asc'

        Gets the repositories for the user 'octocat' sorted by creation date in ascending order.

        .NOTES
        https://docs.github.com/rest/repos/repos#list-repositories-for-a-user

    #>
    [CmdletBinding()]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [string] $Username,

        # Specifies the types of repositories you want returned.
        [Parameter()]
        [validateSet('all', 'owner', 'member')]
        [string] $Type = 'all',

        # The property to sort the results by.
        [Parameter()]
        [validateSet('created', 'updated', 'pushed', 'full_name')]
        [string] $Sort = 'created',

        # The order to sort by.
        # Default: asc when using full_name, otherwise desc.
        [Parameter()]
        [validateSet('asc', 'desc')]
        [string] $Direction,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [GitHubContext] $Context
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
    }

    process {
        try {
            $body = @{
                sort      = $Sort
                type      = $Type
                direction = $Direction
                per_page  = $PerPage
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/users/$Username/repos"
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
        Write-Debug "[$stackPath] - End"
    }
}
