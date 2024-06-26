﻿filter Get-GitHubOrganizationAppInstallation {
    <#
        .SYNOPSIS
        List app installations for an organization

        .DESCRIPTION
        Lists all GitHub Apps in an organization. The installation count includes all GitHub Apps installed on repositories in the organization.
        You must be an organization owner with `admin:read` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubOrganizationAppInstallation -OrganizationName 'github'

        Gets all GitHub Apps in the organization `github`.

        .NOTES
        [List app installations for an organization](https://docs.github.com/rest/orgs/orgs#list-app-installations-for-an-organization)

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('org')]
        [Alias('owner')]
        [Alias('login')]
        [string] $OrganizationName,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        APIEndpoint = "/orgs/$OrganizationName/installations"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response.installations
    }

}
