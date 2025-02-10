function Resolve-GitHubContextSetting {
    <#
        .SYNOPSIS
        Resolves a GitHub context setting based on a provided name.

        .DESCRIPTION
        This function retrieves a setting value from the specified GitHub context. If a value is provided, it
        returns that value; otherwise, it extracts the value from the given context object. This is useful for
        resolving API-related settings dynamically.

        .EXAMPLE
        Resolve-GitHubContextSetting -Name 'Repository' -Context $GitHubContext

        Output:
        ```powershell
        MyRepository
        ```

        Retrieves the 'Repository' setting from the provided GitHub context object.

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
        [string] $Value,

        # The context to resolve into an object. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    if ([string]::IsNullOrEmpty($Value)) {
        $Value = $Context.$Name
    }
    Write-Debug "$Name`:  [$Value]"
    return $Value
}
