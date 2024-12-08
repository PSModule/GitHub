﻿filter Get-GitHubApiVersion {
    <#
        .SYNOPSIS
        Get all API versions.

        .DESCRIPTION
        Get all supported GitHub API versions.

        .EXAMPLE
        Get-GitHubApiVersion

        Get all supported GitHub API versions.

        .NOTES
        [Get all API versions](https://docs.github.com/rest/meta/meta#get-all-api-versions)
    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
    }

    process {
        $inputObject = @{
            Context     = $Context
            ApiEndpoint = '/versions'
            Method      = 'GET'
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
