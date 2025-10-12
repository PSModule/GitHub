function Test-GitHubToken {
    <#
        .SYNOPSIS
        Tests if the GitHub token is set in the environment variables.

        .DESCRIPTION
        This function checks if the GitHub token is available in the environment variables.

        .EXAMPLE
        ```powershell
        Test-GitHubToken
        ```
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param()

    return -not [string]::IsNullOrEmpty((Get-GitHubToken))
}
