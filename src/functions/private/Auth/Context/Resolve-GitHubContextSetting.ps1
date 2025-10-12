function Resolve-GitHubContextSetting {
    <#
        .SYNOPSIS
        Resolves a GitHub context setting based on a provided name.

        .DESCRIPTION
        This function retrieves a setting value from the specified GitHub context. If a value is provided, it
        returns that value; otherwise, it will extract the value from the given context object if provided. As a last resort,
        it will return the default value from the GitHub configuration. This is useful for resolving API-related settings dynamically.

        .EXAMPLE
        ```powershell
        Resolve-GitHubContextSetting -Name 'Repository' -Value 'MyRepo'
        ```

        Output:
        ```powershell
        MyRepo
        ```

        Returns the provided value 'MyRepo' for the 'Repository' setting.

        .EXAMPLE
        ```powershell
        Resolve-GitHubContextSetting -Name 'Repository' -Context $GitHubContext
        ```

        Output:
        ```powershell
        MyRepository
        ```

        Retrieves the 'Repository' setting from the provided GitHub context object.

        .EXAMPLE
        ```powershell
        Resolve-GitHubContextSetting -Name 'ApiBaseUrl'
        ```

        Output:
        ```powershell
        https://api.github.com
        ```

        Returns the default value for the 'ApiBaseUrl' setting from the GitHub configuration when no value or context is provided.

        .LINK
        https://psmodule.io/GitHub/Functions/Resolve-GitHubContextSetting
    #>

    [CmdletBinding()]
    param(
        # The name of the setting to resolve.
        [Parameter(Mandatory)]
        [string] $Name,

        # The value to use for the setting. If not provided, the value will be resolved from the context.
        [Parameter()]
        [object] $Value,

        # The context to resolve into an object. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    if ($Name -eq 'PerPage' -and $Value -eq 0) {
        $Value = $null
    }

    Write-Debug "Resolving setting [$Name]"
    [pscustomobject]@{
        'Name'                 = $Name
        'Parameter Value'      = $Value
        'Context Value'        = $Context.$Name
        'Saved Config Value'   = $script:GitHub.Config.$Name
        'Default Config Value' = $script:GitHub.DefaultConfig.$Name
    } | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }

    if (-not [string]::IsNullOrEmpty($Value)) {
        Write-Debug "[$Name] - [$Value] - Provided value"
        return $Value
    }

    if (-not [string]::IsNullOrEmpty($Context.$Name)) {
        Write-Debug "[$Name] - [$($Context.$Name)] - Context value"
        return $Context.$Name
    }

    if (-not [string]::IsNullOrEmpty($Script:GitHub.Config.$Name)) {
        Write-Debug "[$Name] - [$($script:GitHub.Config.$Name)] - Default value from GitHub.Config"
        return $script:GitHub.Config.$Name
    }

    if (-not [string]::IsNullOrEmpty($Script:GitHub.DefaultConfig.$Name)) {
        Write-Debug "[$Name] - [$($script:GitHub.DefaultConfig.$Name)] - Default value from GitHub.DefaultConfig"
        return $script:GitHub.DefaultConfig.$Name
    }
    Write-Debug ' - No value found, returning'
    return $null
}
