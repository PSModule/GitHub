﻿filter Get-GitHubRepoTeam {
    <#
        .NOTES
        [List repository teams](https://docs.github.com/rest/reference/repos#get-a-repository)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Owner,

        [Parameter(Mandatory)]
        [string] $Repository,

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
            APIEndpoint = "/repos/$Owner/$Repository/teams"
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
