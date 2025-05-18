filter Get-GitHubBlockedUserByOrganization {
    <#
        .SYNOPSIS
        List users blocked by an organization

        .DESCRIPTION
        List the users blocked by an organization.

        .EXAMPLE
        Get-GitHubBlockedUserByOrganization -Organization 'github'

        Lists all users blocked by the organization `github`.

        .NOTES
        [List users blocked by an organization](https://docs.github.com/rest/orgs/blocking#list-users-blocked-by-an-organization)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('login')]
        [string] $Organization,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [System.Nullable[int]] $PerPage,

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
            Method      = 'GET'
            APIEndpoint = "/orgs/$Organization/blocks"
            PerPage     = $PerPage
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
