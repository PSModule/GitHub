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

        .NOTES
        [Delete an organization](https://docs.github.com/rest/orgs/orgs#delete-an-organization)

        .LINK
        https://psmodule.io/GitHub/Functions/Organization/Remove-GitHubOrganization
    #>
    [OutputType([void])]
    [CmdletBinding(DefaultParameterSetName = 'Remove an organization', SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Name,

        # The input object to process. Can be a single or an array of GitHubOrganization objects.
        [Parameter(Mandatory, ParameterSetName = 'ArrayInput', ValueFromPipeline)]
        [GitHubOrganization[]] $InputObject,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ArrayInput' {
                foreach ($item in $InputObject) {
                    $params = @{
                        Name    = $item.Name
                        Context = $Context
                    }
                    Remove-GitHubOrganization @params
                }
                break
            }
            default {
                $apiParams = @{
                    Method      = 'DELETE'
                    APIEndpoint = "/orgs/$Name"
                    Context     = $Context
                }

                if ($PSCmdlet.ShouldProcess("organization [$Name]", 'Delete')) {
                    $null = Invoke-GitHubAPI @apiParams
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
