function Test-GitHubAzPowerShell {
    <#
        .SYNOPSIS
        Tests if Azure PowerShell module is installed and authenticated.

        .DESCRIPTION
        This function checks if the Azure PowerShell module (Az) is installed and the user is authenticated.
        It verifies both the availability of the module and the authentication status.

        .EXAMPLE
        ```powershell
        Test-GitHubAzPowerShell
        ```

        Returns $true if Azure PowerShell module is installed and authenticated, $false otherwise.

        .OUTPUTS
        [bool]
        Returns $true if Azure PowerShell module is installed and authenticated, $false otherwise.

        .NOTES
        This function is used internally by other GitHub module functions that require Azure PowerShell authentication,
        such as Azure Key Vault operations for GitHub App JWT signing.
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param()

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {
            # Check if Azure PowerShell module is installed
            $azModule = Get-Module -Name 'Az.Accounts' -ListAvailable -ErrorAction SilentlyContinue
            if (-not $azModule) {
                Write-Debug "[$stackPath] - Azure PowerShell module (Az.Accounts) not found"
                return $false
            }

            # Check if the module is imported
            $importedModule = Get-Module -Name 'Az.Accounts' -ErrorAction SilentlyContinue
            if (-not $importedModule) {
                Write-Debug "[$stackPath] - Attempting to import Az.Accounts module"
                Import-Module -Name 'Az.Accounts' -ErrorAction SilentlyContinue
            }

            # Check if user is authenticated by trying to get current context
            $context = Get-AzContext -ErrorAction SilentlyContinue
            if (-not $context -or [string]::IsNullOrEmpty($context.Account)) {
                Write-Debug "[$stackPath] - Azure PowerShell authentication failed or no account logged in"
                return $false
            }

            Write-Debug "[$stackPath] - Azure PowerShell is installed and authenticated (Account: $($context.Account.Id))"
            return $true
        } catch {
            Write-Debug "[$stackPath] - Error checking Azure PowerShell: $($_.Exception.Message)"
            return $false
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
