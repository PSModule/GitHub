function Initialize-GitHubConfig {
    <#
        .SYNOPSIS
        Initialize the GitHub module configuration.

        .DESCRIPTION
        Initialize the GitHub module configuration.

        .EXAMPLE
        Initialize-GitHubConfig

        Initializes the GitHub module configuration.

        .EXAMPLE
        Initialize-GitHubConfig -Force

        Forces the initialization of the GitHub module configuration.
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param (
        # Force the initialization of the GitHub config.
        [switch] $Force
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        Write-Debug "Force:           [$Force]"
        if ($Force) {
            Write-Debug 'Forcing initialization of GitHubConfig.'
            $config = Set-Context -Context $script:GitHub.DefaultConfig -Vault $script:GitHub.ContextVault -PassThru
            $script:GitHub.Config = [GitHubConfig]$config
            return
        }

        if ($null -ne $script:GitHub.Config) {
            Write-Debug 'GitHubConfig already initialized and available in memory.'
            return
        }

        Write-Debug 'Attempt to load the stored GitHubConfig from ContextVault'
        $config = Get-Context -ID $script:GitHub.DefaultConfig.ID -Vault $script:GitHub.ContextVault
        if ($config) {
            Write-Debug 'GitHubConfig loaded into memory.'

            Write-Debug 'Synchronizing stored context with GitHubConfig class definition.'
            $needsUpdate = $false
            $validProperties = [GitHubConfig].GetProperties().Name
            $storedProperties = $config.PSObject.Properties.Name

            # Add missing properties from DefaultConfig
            foreach ($propName in $validProperties) {
                Write-Debug "Validating property [$propName]"
                if (-not $storedProperties.Contains($propName)) {
                    Write-Debug "Adding missing property [$propName] from DefaultConfig"
                    $defaultValue = $script:GitHub.DefaultConfig.$propName
                    $config | Add-Member -MemberType NoteProperty -Name $propName -Value $defaultValue
                    $needsUpdate = $true
                }
            }

            # Remove obsolete properties that are no longer supported
            $propertiesToRemove = @()
            foreach ($propName in $storedProperties) {
                Write-Debug "Checking property [$propName] for obsolescence"
                if (-not $validProperties.Contains($propName)) {
                    Write-Debug "Removing obsolete property [$propName] from stored context"
                    $propertiesToRemove += $propName
                    $needsUpdate = $true
                }
            }

            # Remove the obsolete properties
            foreach ($propName in $propertiesToRemove) {
                $config.PSObject.Properties.Remove($propName)
            }

            if ($needsUpdate) {
                Write-Debug 'Updating stored context with synchronized properties'
                $config = Set-Context -Context $config -Vault $script:GitHub.ContextVault -PassThru
            }

            $script:GitHub.Config = [GitHubConfig]$config
            return
        }
        Write-Debug 'Initializing GitHubConfig from defaults'
        $config = Set-Context -Context $script:GitHub.DefaultConfig -Vault $script:GitHub.ContextVault -PassThru
        $script:GitHub.Config = [GitHubConfig]$config
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '8.1.3' }
