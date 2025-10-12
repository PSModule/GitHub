function Test-GitHubAzureCLI {
    <#
        .SYNOPSIS
        Tests if Azure CLI is installed and authenticated.

        .DESCRIPTION
        This function checks if Azure CLI (az) is installed and the user is authenticated.
        It verifies both the availability of the CLI tool and the authentication status.

        .EXAMPLE
        ```powershell
        Test-GitHubAzureCLI
        ```

        Returns $true if Azure CLI is installed and authenticated, $false otherwise.

        .OUTPUTS
        bool

        .NOTES
        This function is used internally by other GitHub module functions that require Azure CLI authentication,
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
            # Check if Azure CLI is installed
            $azCommand = Get-Command -Name 'az' -ErrorAction SilentlyContinue
            if (-not $azCommand) {
                Write-Debug "[$stackPath] - Azure CLI (az) command not found"
                return $false
            }

            # Check if user is authenticated by trying to get account info
            $accountInfo = az account show --output json 2>$null
            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($accountInfo)) {
                Write-Debug "[$stackPath] - Azure CLI authentication failed or no account logged in"
                return $false
            }

            # Parse the account info to ensure it's valid
            $account = $accountInfo | ConvertFrom-Json -ErrorAction SilentlyContinue
            if (-not $account -or [string]::IsNullOrEmpty($account.id)) {
                Write-Debug "[$stackPath] - Azure CLI account information is invalid"
                return $false
            }

            Write-Debug "[$stackPath] - Azure CLI is installed and authenticated (Account: $($account.id))"
            return $true
        } catch {
            Write-Debug "[$stackPath] - Error checking Azure CLI: $($_.Exception.Message)"
            return $false
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
