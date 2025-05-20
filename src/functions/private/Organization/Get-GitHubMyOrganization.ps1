filter Get-GitHubMyOrganization {
    <#
        .SYNOPSIS
        List organizations for the authenticated user

        .DESCRIPTION
        List organizations for the authenticated user.

        **OAuth scope requirements**

        This only lists organizations that your authorization allows you to operate on
        in some way (e.g., you can list teams with `read:org` scope, you can publicize your
        organization membership with `user` scope, etc.). Therefore, this API requires at
        least `user` or `read:org` scope. OAuth requests with insufficient scope receive a
        `403 Forbidden` response.

        .EXAMPLE
        Get-GitHubMyOrganization

        List organizations for the authenticated user.

        .OUTPUTS
        GitHubOrganization

        .NOTES
        [List organizations for the authenticated user](https://docs.github.com/rest/orgs/orgs#list-organizations-for-the-authenticated-user)
    #>
    [OutputType([GitHubOrganization])]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
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
            APIEndpoint = '/user/orgs'
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $_.Response | ForEach-Object { [GitHubOrganization]::new($_) }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
