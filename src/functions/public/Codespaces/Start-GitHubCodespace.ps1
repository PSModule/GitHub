function Start-GitHubCodespace {
    <#
    .SYNOPSIS
        Start a codespace.

    .PARAMETER Name
        The name of the codespace.

    .PARAMETER Wait
        If present will wait for the codespace to start.

    .EXAMPLE
        > Start-GitHubCodespace -Name urban-dollop-pqxgrq55v4c97g4

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#start-a-codespace-for-the-authenticated-user
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param (
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
                "Starting GitHub codespace [$Name]",
                "Are you sure you want to start GitHub codespace [$Name]?",
                'Start GitHub codespace'
            )) {
            $postParams = @{
                APIEndpoint = $PSCmdlet.ParameterSetName -eq 'Organization' ?
                    "/orgs/$Organization/members/$User/codespaces/$Name/start" :
                    "/user/codespaces/$Name/start"
                Context     = $Context
                Method = 'POST'
            }
            $codespace = Invoke-GitHubAPI @postParams | Select-Object -ExpandProperty Response
            # | Add-ObjectDetail -TypeName GitHub.Codespace -DefaultProperties name, display_name, location, state, created_at, updated_at, last_used_at
            if ($Wait.IsPresent) {
                $getParams = @{ Name = $Name }
                $codespace = Wait-GitHubCodespaceAction -GetParameters $getParams
            }
            $codespace
        }
    }
}
