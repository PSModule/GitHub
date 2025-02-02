function Set-GitHubCodespace {
    <#
    .SYNOPSIS
         Update a codespace.

    .PARAMETER Name
        The name of the codespace.

     .PARAMETER Ref
        Git ref (typically a branch name) for this codespace

     .PARAMETER Location
        The requested location for a new codespace. Best efforts are made to respect this upon creation. Assigned by IP if not provided.

     .PARAMETER ClientIp
        IP for location auto-detection when proxying a request

     .PARAMETER Machine
        Machine type to use for this codespace

     .PARAMETER Devcontainer
        Path to devcontainer.json config to use for this codespace

     .PARAMETER NoMultipleRepoPermissions
        Whether to authorize requested permissions from devcontainer.json

     .PARAMETER WorkingDirectory
        Working directory for this codespace

     .PARAMETER Timeout
        Time in minutes before codespace stops from inactivity

     .PARAMETER DisplayName
        Display name for this codespace

     .PARAMETER RetentionPeriod
        Duration in minutes after codespace has gone idle in which it will be deleted. Must be integer minutes between 0 and 43200 (30 days).

    .EXAMPLE
        > Set-GitHubCodespace -Name fluffy-disco-v7xgv7j4j52pvw9 -DisplayName 'vigilant doodle'

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#update-a-codespace-for-the-authenticated-user
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [ValidateSet('basicLinux32gb', 'standardLinux32gb', 'premiumLinux', 'largePremiumLinux')]
        [string]$Machine,
        [string]$DisplayName,
        [string[]]$RecentFolders,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    begin {
        $propertyMap = @{
            DisplayName   = 'display_name'
            Machine       = 'machine'
            RecentFolders = 'recent_folders'
        }
    }
    process {
        $properties = @{}
        foreach ($p in $PSBoundParameters.GetEnumerator()) {
            if ($propertyMap.ContainsKey($p.Key) -and -not [string]::IsNullOrWhiteSpace($p.Value)) {
                $properties.Add($propertyMap[$p.Key], $p.Value)
            }
        }
        if ($properties.Count -gt 0) {
            if ($PSCmdLet.ShouldProcess(
                    "Updating github codespace [$Name]",
                    "Are you sure you want to update github codespace [$Name]?",
                    'Update codespace'
                )) {
                $patchParams = @{
                    APIEndpoint = "/user/codespaces/$Name"
                    Body        = [PSCustomObject]$properties | ConvertTo-Json
                    Context     = $Context
                    Method      = 'PATCH'
                }
                Invoke-GitHubAPI @patchParams | Select-Object -ExpandProperty Response | ConvertTo-GitHubCodespace
                # | Add-ObjectDetail -TypeName GitHub.Codespace -DefaultProperties name,display_name,location,state,created_at,updated_at,last_used_at
            }
        }
    }
}
