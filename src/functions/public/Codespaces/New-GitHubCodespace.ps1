function New-GitHubCodespace {
    <#
    .SYNOPSIS
         Create a codespace.

    .PARAMETER Owner
        The account owner of the repository. The name is not case sensitive.

    .PARAMETER Repository
        The name of the repository. The name is not case sensitive.

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
        > New-GitHubCodespace -Owner PSModule -Repository Sodium

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#create-a-codespace-in-a-repository

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#create-a-codespace-from-a-pull-request

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#create-a-codespace-for-the-authenticated-user
    #>
    [CmdletBinding(DefaultParameterSetName = 'User', SupportsShouldProcess)]
    param (
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [Parameter(ParameterSetName = 'PullRequest', Mandatory)]
        [string]$Owner,

        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [Parameter(ParameterSetName = 'PullRequest', Mandatory)]
        [string]$Repository,

        [Parameter(ParameterSetName = 'PullRequest', Mandatory)]
        [Parameter(ParameterSetName = 'User')]
        [int]$PullNumber,

        [Parameter(ParameterSetName = 'User', Mandatory)]
        [int]$RepositoryId,

        [Parameter(ParameterSetName = 'Repository')]
        [Parameter(ParameterSetName = 'User')]
        [string]$Ref,

        [ValidateSet('EastUs', 'SouthEastAsia', 'WestEurope', 'WestUs2')]
        [string]$Location,
        [string]$ClientIp,
        [ValidateSet('basicLinux32gb', 'standardLinux32gb', 'premiumLinux', 'largePremiumLinux')]
        [string]$Machine,
        [string]$Devcontainer,
        [switch]$NoMultipleRepoPermissions,
        [string]$WorkingDirectory,
        [int]$Timeout,
        [string]$DisplayName,
        [int]$RetentionPeriod,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    begin {
        $propertyMap = @{
            ClientIp         = 'client_ip'
            Devcontainer     = 'devcontainer_path'
            DisplayName      = 'display_name'
            Location         = 'location'
            Machine          = 'machine'
            Ref              = 'ref'
            RetentionPeriod  = 'retention_period_minutes'
            Timeout          = 'idle_timeout_minutes'
            WorkingDirectory = 'working_directory'
        }
    }
    process {
        if ($PSCmdLet.ShouldProcess(
                'Creating GitHub codespace',
                'Are you sure you want to create a new codespace?',
                'Create codespace'
            )) {
            $properties = @{
                multi_repo_permissions_opt_out = $NoMultipleRepoPermissions.IsPresent
            }
            foreach ($p in $PSBoundParameters.GetEnumerator()) {
                if ($propertyMap.ContainsKey($p.Key) -and -not [string]::IsNullOrWhiteSpace($p.Value)) {
                    $properties.Add($propertyMap[$p.Key], $p.Value)
                }
            }
            if ($PSCmdlet.ParameterSetName -eq 'User') {
                if ($PSBoundParameters.ContainsKey('PullRequest')) {
                    $properties.Add('pull_request', [PSCustomObject]@{
                            pull_request_number = $PullNumber
                            repository_id       = $RepositoryId
                        })
                }
                else {
                    $properties.Add('repository_id', $RepositoryId)
                }
            }
            $postParams = @{
                APIEndpoint = switch ($PSCmdlet.ParameterSetName) {
                    'PullRequest' {
                        "/repos/$Owner/$Repository/pulls/$PullNumber/codespaces"
                        break
                    }
                    'Repository' {
                        "/repos/$Owner/$Repository/codespaces"
                        break
                    }
                    'User' {
                        '/user/codespaces'
                        break
                    }
                }
                Body        = [PSCustomObject]$properties | ConvertTo-Json
                Context     = $Context
                Method      = 'POST'
            }
            Invoke-GitHubAPI @postParams | Select-Object -ExpandProperty Response | ConvertTo-GitHubCodespace
            # | Add-ObjectDetail -TypeName GitHub.Codespace -DefaultProperties name, display_name, location, state, created_at, updated_at, last_used_at
        }
    }
}
