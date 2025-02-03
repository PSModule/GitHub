filter Block-GitHubUserByOrganization {
    <#
        .SYNOPSIS
        Block a user from an organization

        .DESCRIPTION
        Blocks the given user on behalf of the specified organization and returns a 204.
        If the organization cannot block the given user a 422 is returned.

        .EXAMPLE
        Block-GitHubUserByOrganization -Organization 'github' -Username 'octocat'

        Blocks the user 'octocat' from the organization 'github'.
        Returns $true if successful, $false if not.

        .NOTES
        https://docs.github.com/rest/orgs/blocking#block-a-user-from-an-organization
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('org')]
        [Alias('owner')]
        [Alias('login')]
        [string] $Organization,

        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [GitHubContext] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'PUT'
            APIEndpoint = "/orgs/$Organization/blocks/$Username"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
