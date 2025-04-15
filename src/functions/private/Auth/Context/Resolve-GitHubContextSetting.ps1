function Resolve-GitHubContextSetting {
    <#
        .SYNOPSIS
        Resolves a GitHub context setting based on a provided name.

        .DESCRIPTION
        This function retrieves a setting value from the specified GitHub context. If a value is provided, it
        returns that value; otherwise, it will extract the value from the given context object if provided. As a last resort,
        it will return the default value from the GitHub configuration. This is useful for resolving API-related settings dynamically.

        .EXAMPLE
        Resolve-GitHubContextSetting -Name 'Repository' -Value 'MyRepo'

        Output:
        ```powershell
        MyRepo
        ```

        Returns the provided value 'MyRepo' for the 'Repository' setting.

        .EXAMPLE
        Resolve-GitHubContextSetting -Name 'Repository' -Context $GitHubContext

        Output:
        ```powershell
        MyRepository
        ```

        Retrieves the 'Repository' setting from the provided GitHub context object.

        .EXAMPLE
        Resolve-GitHubContextSetting -Name 'ApiBaseUrl'

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

    if ($Value) {
        Write-Debug "[$Name] - [$Value] - Provided value"
        return $Value
    }
    if ($Context) {
        Write-Debug "[$Name] - [$Context] - Context value"
        return $Context.$Name
    }
    if ($Script:GitHub.Config.$Name) {
        Write-Debug "[$Name] - [$($script:GitHub.Config.$Name)] - Default value from GitHub.Config"
        return $script:GitHub.Config.$Name
    }
    Write-Debug "[$Name] - [$($script:GitHub.Config.$Name)] - No value found, returning"
    return $null
}
