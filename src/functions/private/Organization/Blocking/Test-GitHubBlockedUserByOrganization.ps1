﻿filter Test-GitHubBlockedUserByOrganization {
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
            Context     = $Context
            APIEndpoint = "/orgs/$Organization/blocks/$Username"
            Method      = 'GET'
        }

        try {
            (Invoke-GitHubAPI @inputObject).StatusCode -eq 204
        } catch {
            if ($_.Exception.Response.StatusCode.Value__ -eq 404) {
                return $false
            } else {
                throw $_
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

