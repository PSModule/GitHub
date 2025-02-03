﻿filter Get-GitHubZen {
    <#
        .SYNOPSIS
        Get the Zen of GitHub.

        .DESCRIPTION
        Get a random sentence from the Zen of GitHub.

        .EXAMPLE
        Get-GitHubZen

        Get a random sentence from the Zen of GitHub.

        .NOTES
        [Get the Zen of GitHub](https://docs.github.com/rest/meta/meta#get-the-zen-of-github)
    #>
    [CmdletBinding()]
    param(
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
        try {
            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/zen'
                Method      = 'Get'
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
