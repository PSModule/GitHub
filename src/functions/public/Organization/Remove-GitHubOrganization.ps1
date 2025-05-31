filter Remove-GitHubOrganization {
    <#
        .SYNOPSIS
        Delete an organization

        .DESCRIPTION
        Deletes an organization and all its repositories.
        The organization login will be unavailable for 90 days after deletion.
        Please review the [GitHub Terms of Service](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
        regarding account deletion before using this endpoint.

        .EXAMPLE
        Remove-GitHubOrganization -Name 'GitHub'

        Deletes the organization 'GitHub' and all its repositories.

        .INPUTS
GitHubOrganization

        .LINK
        https://psmodule.io/GitHub/Functions/Organization/Remove-GitHubOrganization/

                https://psmodule.io/GitHub/Functions/Organization/Remove-GitHubOrganization

        .NOTES
        [Delete an organization](https://docs.github.com/rest/orgs/orgs#delete-an-organization)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

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
            APIEndpoint = "/orgs/$Name"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("organization [$Name]", 'DELETE')) {
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
