function Get-GitHubToken {
    <#
        .SYNOPSIS
        Retrieves a GitHub token from environment variables as plaintext or a secure string.

        .DESCRIPTION
        Returns the value of the `GH_TOKEN` or `GITHUB_TOKEN` environment variable. If the `AsPlainText`
        switch is provided, the token is returned as a plaintext string. If not, the token is returned as
        a secure string using `ConvertTo-SecureString`. This allows flexibility for consumers who require
        either a raw token value or a secure version for sensitive operations.

        .EXAMPLE
        Get-GitHubToken

        Output:
        ```powershell
        System.Security.SecureString
        ```

        Returns the GitHub token as a secure string for safer handling in scripts or automation.

        .EXAMPLE
        Get-GitHubToken -AsPlainText

        Output:
        ```powershell
        ghp_XXXXXXXXXXXXXXXXXXXXXX
        ```

        Returns the GitHub token as a plaintext string if set in the environment.

        .OUTPUTS
        System.String

        .OUTPUTS
        System.Security.SecureString

        .LINK
        https://psmodule.io/GitHub/Functions/Get-GitHubToken/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'The token is already plaintext.'
    )]
    [OutputType([System.Security.SecureString], ParameterSetName = 'SecureString')]
    [OutputType([System.String], ParameterSetName = 'String')]
    [CmdletBinding(DefaultParameterSetName = 'SecureString')]
    param(
        # Returns the token as a plaintext string when specified.
        [Parameter(Mandatory, ParameterSetName = 'String')]
        [switch] $AsPlainText
    )

    $token = $env:GH_TOKEN ?? $env:GITHUB_TOKEN

    if ([string]::IsNullOrEmpty($token)) {
        return
    }

    if ($AsPlainText) {
        return $token
    }

    return $token | ConvertTo-SecureString -AsPlainText -Force
}
