function Remove-GitHubTeam {
    <#
        .SYNOPSIS
        Delete a team

        .DESCRIPTION
        To delete a team, the authenticated user must be an organization owner or team maintainer.
        If you are an organization owner, deleting a parent team will delete all of its child teams as well.

        .EXAMPLE
        Remove-GitHubTeam -Organization 'github' -Name 'team-name'

        .NOTES
        [Delete a team](https://docs.github.com/rest/teams/teams#delete-a-team)        .LINK
        https://psmodule.io/GitHub/Functions/Teams/Remove-GitHubTeam/

                https://psmodule.io/GitHub/Functions/Teams/Remove-GitHubTeam
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The organization name. The name is not case sensitive.
        # If not provided, the organization from the context is used.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Organization,

        # The slug of the team name.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Slug,

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
            Method      = 'DELETE'
            APIEndpoint = "/orgs/$Organization/teams/$Slug"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Organization/$Slug", 'DELETE')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
