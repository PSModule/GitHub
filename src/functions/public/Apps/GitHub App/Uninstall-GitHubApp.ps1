function Uninstall-GitHubApp {
    <#
        .SYNOPSIS
        Uninstall a GitHub App.

        .DESCRIPTION
        Uninstalls a GitHub App installation. Works in two modes:
        - As the authenticated App (APP context): remove installations by target name, ID, or pipeline objects.
        - As an enterprise installation (IAT/UAT context with Enterprise): remove an app from an organization by InstallationID or AppSlug.

        .EXAMPLE
        ```powershell
        Uninstall-GitHubApp -Target 'octocat'
        Uninstall-GitHubApp -Target 12345
        ```

        As an App: uninstall by target name (enterprise/org/user) or by exact installation ID

        .EXAMPLE
        ```powershell
        Get-GitHubAppInstallation | Uninstall-GitHubApp
        ```

        As an App: uninstall using pipeline objects

        .EXAMPLE
        ```powershell
        Uninstall-GitHubApp -Organization 'org' -InstallationID 123456 -Context (Connect-GitHubApp -Enterprise 'msx' -PassThru)
        ```

        As an enterprise installation: uninstall by installation ID in an org

        .EXAMPLE
        ```powershell
        Uninstall-GitHubApp -Organization 'org' -AppSlug 'my-app' -Context (Connect-GitHubApp -Enterprise 'msx' -PassThru)
        ```

        As an enterprise installation: uninstall by app slug in an org

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/Uninstall-GitHubApp
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'App-ByTarget')]
    param(
        # As APP: target to uninstall. Accepts a name (enterprise/org/user) or an installation ID.
        [Parameter(Mandatory, ParameterSetName = 'App-ByTarget', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'App-ByObject')]
        [Alias('Name')]
        [object] $Target,

        # As APP via pipeline: installation objects.
        [Parameter(Mandatory, ParameterSetName = 'App-ByObject', ValueFromPipeline)]
        [GitHubAppInstallation[]] $InstallationObject,

        # As Enterprise (IAT/UAT): organization where the app is installed.
        [Parameter(Mandatory, ParameterSetName = 'Enterprise-ByID')]
        [Parameter(Mandatory, ParameterSetName = 'Enterprise-BySlug')]
        [ValidateNotNullOrEmpty()]
        [string] $Organization,

        # As Enterprise (IAT/UAT): enterprise slug or ID. Optional if the context already has Enterprise set.
        [Parameter(ParameterSetName = 'Enterprise-ByID')]
        [Parameter(ParameterSetName = 'Enterprise-BySlug')]
        [ValidateNotNullOrEmpty()]
        [string] $Enterprise,

        # As Enterprise (IAT/UAT): installation ID to remove.
        [Parameter(Mandatory, ParameterSetName = 'Enterprise-ByID')]
        [Alias('ID')]
        [ValidateRange(1, [UInt64]::MaxValue)]
        [UInt64] $InstallationID,

        # As Enterprise (IAT/UAT): app slug to uninstall (when the installation ID is unknown).
        [Parameter(Mandatory, ParameterSetName = 'Enterprise-BySlug')]
        [Alias('Slug', 'AppName')]
        [ValidateNotNullOrEmpty()]
        [string] $AppSlug,

        # Common: explicit context (APP for app mode; IAT/UAT with Enterprise for enterprise mode)
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType APP, IAT, UAT
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'App-ByTarget' {
                if ($Context.AuthType -ne 'APP') {
                    throw 'App-ByTarget requires APP authentication. Provide an App context or connect as an App.'
                }

                $id = $null
                if ($Target -is [int] -or $Target -is [long] -or $Target -is [uint64]) { $id = [uint64]$Target }
                elseif ($Target -is [string] -and ($Target -as [uint64])) { $id = [uint64]$Target }

                if ($id) {
                    if ($PSCmdlet.ShouldProcess("GitHub App Installation: $id", 'Uninstall')) {
                        Uninstall-GitHubAppAsApp -ID $id -Context $Context -Confirm:$false
                    }
                    return
                }

                $installations = Get-GitHubAppInstallation -Context $Context
                $instMatches = $installations | Where-Object { $_.Target.Name -like "*$Target*" }
                if (-not $instMatches) { throw "No installations found matching target '$Target'." }
                foreach ($inst in $instMatches) {
                    if ($PSCmdlet.ShouldProcess("GitHub App Installation: $($inst.ID) [$($inst.Target.Type)/$($inst.Target.Name)]", 'Uninstall')) {
                        Uninstall-GitHubAppAsApp -ID $inst.ID -Context $Context -Confirm:$false
                    }
                }
            }

            'App-ByObject' {
                if ($Context.AuthType -ne 'APP') {
                    throw 'App-ByObject requires APP authentication. Provide an App context or connect as an App.'
                }
                foreach ($inst in $InstallationObject) {
                    if (-not $inst.ID) { continue }
                    if ($PSCmdlet.ShouldProcess("GitHub App Installation: $($inst.ID) [$($inst.Target.Type)/$($inst.Target.Name)]", 'Uninstall')) {
                        Uninstall-GitHubAppAsApp -ID $inst.ID -Context $Context -Confirm:$false
                    }
                }
            }

            'Enterprise-ByID' {
                $effectiveEnterprise = if ($Enterprise) { $Enterprise } else { $Context.Enterprise }
                if (-not $effectiveEnterprise) { throw 'Enterprise-ByID requires an enterprise to be specified (via -Enterprise or Context.Enterprise).' }
                $params = @{
                    Enterprise   = $effectiveEnterprise
                    Organization = $Organization
                    ID           = $InstallationID
                    Context      = $Context
                }
                if ($PSCmdlet.ShouldProcess("GitHub App Installation: $effectiveEnterprise/$Organization/$InstallationID", 'Uninstall')) {
                    Uninstall-GitHubAppOnEnterpriseOrganization @params -Confirm:$false
                }
            }

            'Enterprise-BySlug' {
                $effectiveEnterprise = if ($Enterprise) { $Enterprise } else { $Context.Enterprise }
                if (-not $effectiveEnterprise) { throw 'Enterprise-BySlug requires an enterprise to be specified (via -Enterprise or Context.Enterprise).' }
                $inst = Get-GitHubAppInstallationForEnterpriseOrganization -Enterprise $effectiveEnterprise -Organization $Organization -Context $Context |
                    Where-Object { $_.App.Slug -eq $AppSlug } | Select-Object -First 1
                if (-not $inst) { throw "No installation found for app slug '$AppSlug' in org '$Organization'." }
                $params = @{
                    Enterprise   = $effectiveEnterprise
                    Organization = $Organization
                    ID           = $inst.ID
                    Context      = $Context
                }
                if ($PSCmdlet.ShouldProcess("GitHub App Installation: $effectiveEnterprise/$Organization/$($inst.ID) (app '$AppSlug')", 'Uninstall')) {
                    Uninstall-GitHubAppOnEnterpriseOrganization @params -Confirm:$false
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
