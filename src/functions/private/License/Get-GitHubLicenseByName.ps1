﻿filter Get-GitHubLicenseByName {
    <#
        .SYNOPSIS
        Get a license

        .DESCRIPTION
        Gets information about a specific license.
        For more information, see "[Licensing a repository ](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)."

        .EXAMPLE
        Get-GitHubGitignoreList

        Get all gitignore templates

        .NOTES
        https://docs.github.com/rest/licenses/licenses#get-a-license

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding()]
    param(
        # The license keyword, license name, or license SPDX ID. For example, mit or mpl-2.0.
        [Parameter(Mandatory)]
        [Alias('license')]
        [string] $Name,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $Context = Resolve-GitHubContext -Context $Context
    }

    process {
        $inputObject = @{
            Context     = $Context
            APIEndpoint = "/licenses/$Name"
            Accept      = 'application/vnd.github+json'
            Method      = 'GET'
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
