filter Test-GitHubBlockedUserByOrganization {
    <#
        .SYNOPSIS
        Check if a user is blocked by an organization

        .DESCRIPTION
        Returns a 204 if the given user is blocked by the given organization.
        Returns a 404 if the organization is not blocking the user, or if the user account has been identified as spam by GitHub.

        .EXAMPLE
        Test-GitHubBlockedUserByOrganization -Organization 'PSModule' -Username 'octocat'

        Checks if the user `octocat` is blocked by the organization `PSModule`.
        Returns true if the user is blocked, false if not.

        .NOTES
        https://docs.github.com/rest/orgs/blocking#check-if-a-user-is-blocked-by-an-organization
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
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [GitHubContext] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'Get'
            APIEndpoint = "/orgs/$Organization/blocks/$Username"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
