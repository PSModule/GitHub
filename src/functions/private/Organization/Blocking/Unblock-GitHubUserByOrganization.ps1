filter Unblock-GitHubUserByOrganization {
    <#
        .SYNOPSIS
        Unblock a user from an organization

        .DESCRIPTION
        Unblocks the given user on behalf of the specified organization.

        .EXAMPLE
        Unblock-GitHubUserByOrganization -Organization 'github' -Username 'octocat'

        Unblocks the user 'octocat' from the organization 'github'.
        Returns $true if successful.

        .NOTES
        https://docs.github.com/rest/orgs/blocking#unblock-a-user-from-an-organization
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
        [Alias('login')]
        [string] $Username,

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
        $inputObject = @{
            Method      = 'Delete'
            APIEndpoint = "/orgs/$Organization/blocks/$Username"
            Context     = $Context
        }
        Invoke-GitHubAPI @inputObject
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
