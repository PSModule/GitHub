function New-GitHubOrganization {
    <#
        .SYNOPSIS
        Creates a new GitHub organization within a specified enterprise.

        .DESCRIPTION
        This function creates a new GitHub organization within the specified enterprise.

        .EXAMPLE
        New-GitHubOrganization -Enterprise 'my-enterprise' -Name 'my-org' -Owner 'user1' -BillingEmail 'billing@example.com'

        .OUTPUTS
        GitHubOrganization

        .LINK
        https://psmodule.io/GitHub/Functions/Organization/New-GitHubOrganization/
    #>
    [OutputType([GitHubOrganization])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        # The name of the enterprise to create the organization in.
        [Parameter()]
        [string]$Enterprise,

        # The name of the organization to create.
        [Parameter(Mandatory)]
        [string]$Name,

        # The owners of the organization. This should be a list of GitHub usernames.
        [Parameter(Mandatory)]
        [string[]]$Owner,

        # The billing email for the organization.
        [Parameter()]
        [string]$BillingEmail,

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
        $enterpriseObject = Get-GitHubEnterprise -Name $Enterprise -Context $Context
        Write-Verbose "Creating organization in enterprise: $($enterpriseObject.Name)"
        $graphQLFields = ([GitHubOrganization]::PropertyToGraphQLMap).Values

        $inputParams = @{
            adminLogins  = $Owner
            billingEmail = $BillingEmail
            enterpriseId = $enterpriseObject.NodeID
            login        = $Name
            profileName  = $Name
        }

        $updateGraphQLInputs = @{
            Query     = @"
mutation(`$input:CreateEnterpriseOrganizationInput!) {
    createEnterpriseOrganization(input:`$input) {
        organization {
            $graphQLFields
        }
    }
}
"@
            Variables = @{
                input = $inputParams
            }
            Context   = $Context
        }
        if ($PSCmdlet.ShouldProcess("Creating organization '$Name' in enterprise '$Enterprise'")) {
            $orgresult = Invoke-GitHubGraphQLQuery @updateGraphQLInputs
            $org = $orgresult.createEnterpriseOrganization.organization
            $org | Add-Member -NotePropertyName Url -NotePropertyValue "$($Context.HostName)/$($org.login)" -Force
            [GitHubOrganization]::new($org)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

