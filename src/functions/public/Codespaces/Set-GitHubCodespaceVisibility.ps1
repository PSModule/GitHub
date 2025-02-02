function Set-GitHubCodespaceVisibility {
    <#
    .SYNOPSIS
        Manage access control for organization codespaces.

    .DESCRIPTION
        Sets which users can access codespaces in an organization.
        This is synonymous with granting or revoking codespaces access permissions for users according to the visibility.
        You must authenticate using an access token with the admin:org scope to use this endpoint.

    .PARAMETER Organization
        The organization name. The name is not case sensitive.

    .PARAMETER User
        The usernames of the organization members who should have access to codespaces in the organization.

        Required when visibility is selected_members. The provided list of usernames will replace any existing value.

    .PARAMETER Visibility
        Which users can access codespaces in the organization. disabled means that no users can access codespaces in the organization.

    .PARAMETER Force
        When specified, forces execution without confirmation.

    .EXAMPLE
        Set-GitHubCodespaceVisibility -Visibility selected_members -User fake_user_name -Force

    .LINK
        https://docs.github.com/en/rest/codespaces/organizations?apiVersion=2022-11-28#manage-access-control-for-organization-codespaces
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,
        [ValidateSet('disabled', 'selected_members', 'all_members', 'all_members_and_outside_collaborators')]
        [string]$Visibility,

        [switch]$Force,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    dynamicparam {
        if ($Visibility -eq 'selected_members') {
            $paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
            # Add a mandatory string array parameter called 'User'
            $attributeCollection = @( [Management.Automation.ParameterAttribute]@{ Mandatory = $true } )
            $paramDictionary.Add('User', [Management.Automation.RuntimeDefinedParameter]::new('User', [String[]], $attributeCollection))
            $paramDictionary
        }
    }
    process {
        if ($Force.IsPresent -and -not $Confirm) { $ConfirmPreference = 'None' }
        if ($PSCmdLet.ShouldProcess(
                "Changing codespace visibility to [$($Visibility)]",
                "Are you sure you want to set visibility to $($Visibility)?",
                'Change codespace visibility')) {
            $properties = @{ visibility = $Visibility }
            if ($Visibility -eq 'selected_members') {
                $properties.Add('selected_usernames', @($PSBoundParameters.User))
            }
            $putParams = @{
                APIEndpoint = "/orgs/$Organization/codespaces/access"
                Body        = [PSCustomObject]$properties | ConvertTo-Json
                Context     = $Context
                Method      = 'PUT'
            }
            Invoke-GitHubAPI @putParams | Select-Object -ExpandProperty Response
        }
    }
}
