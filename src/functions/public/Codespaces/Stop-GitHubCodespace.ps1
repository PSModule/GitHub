function Stop-GitHubCodespace {
    <#
    .SYNOPSIS
        Stop a codespace.

    .PARAMETER Organization
        The organization name. The name is not case sensitive.

    .PARAMETER User
        The handle for the GitHub user account.

    .PARAMETER Name
        The name of the codespace.

    .PARAMETER Wait
        If present will wait for the codespace to stop.

    .EXAMPLE
        > Stop-GitHubCodespace -Name urban-dollop-pqxgrq55v4c97g4

    .EXAMPLE
        > Stop-GitHubCodespace -User fake_user_name -Name urban-dollop-pqxgrq55v4c97g4

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#stop-a-codespace-for-the-authenticated-user

    .LINK
        https://docs.github.com/en/rest/codespaces/organizations?apiVersion=2022-11-28#stop-a-codespace-for-an-organization-user
    #>
    [CmdletBinding(DefaultParameterSetName = 'User', SupportsShouldProcess)]
    param (
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [string]$Organization,
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [string]$User,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Name,

        [switch]$Wait,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    process {
        if ($PSCmdLet.ShouldProcess(
                "Stopping GitHub codespace [$Name]",
                "Are you sure you want to stop GitHub codespace $($Name)?",
                'Stop codespace'
            )) {
            $postParams = @{
                APIEndpoint = $PSCmdlet.ParameterSetName -eq 'Organization' ?
                    "/orgs/$Organization/members/$User/codespaces/$Name/stop" :
                    "/user/codespaces/$Name/stop"
                Context     = $Context
                Method      = 'POST'
            }
            $codespace = Invoke-GitHubAPI @postParams | Select-Object -ExpandProperty Response
            # | Add-ObjectDetail -TypeName GitHub.Codespace -DefaultProperties name, display_name, location, state, created_at, updated_at, last_used_at
            if ($Wait.IsPresent) {
                $getParams = $PSCmdlet.ParameterSetName -eq 'Organization' ?
                @{ Organization = $Organization; User = $User } :
                @{ Name = $Name }
                $codespace = Wait-GitHubCodespaceAction -GetParameters $getParams
            }
            $codespace
        }
    }
}
