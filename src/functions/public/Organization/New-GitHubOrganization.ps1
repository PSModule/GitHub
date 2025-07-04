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
        [Parameter()]
        [string]$Enterprise,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string[]]$Owner,

        [Parameter()]
        [string]$BillingEmail,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )


    $enterpriseObject = Get-GitHubEnterprise -Name $Enterprise -Context $Context
    Write-Verbose "Creating organization in enterprise: $($enterpriseObject.Name)"

    $inputParams = @{
        adminLogins  = $Owner
        billingEmail = $BillingEmail
        enterpriseId = $enterpriseObject.NodeID
        login        = $Name
        profileName  = $Name
    }

    $updateGraphQLInputs = @{
        Query     = @'
    mutation($input:CreateEnterpriseOrganizationInput!) {
        createEnterpriseOrganization(input:$input) {
            organization {
                id
                login
            }
        }
    }
'@
        Variables = @{
            input = $inputParams
        }
        Context   = $Context
    }
    if ($PSCmdlet.ShouldProcess("Creating organization '$Name' in enterprise '$Enterprise'")) {
        $orgresult = Invoke-GitHubGraphQLQuery @updateGraphQLInputs
        [GitHubOrganization]::new($orgresult.createEnterpriseOrganization.organization)
    }
}
