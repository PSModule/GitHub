function Get-GitHubAccessToken {
    <#
        .SYNOPSIS
        Retrieves the GitHub access token from the specified context.

        .DESCRIPTION
        Returns the access token from the provided context.
        If the -AsPlainText switch is specified, the token is returned as a plain text string;
        otherwise, the original secure string or string value is returned as stored in the context.
        Use this function to extract authentication tokens for subsequent API requests.

        .EXAMPLE
        ```powershell
        Get-GitHubAccessToken
        ```

        Output:
        ```powershell
        System.Security.SecureString
        ```

        Retrieves the access token from the default context as a secure string.

        .EXAMPLE
        ```powershell
        Get-GitHubAccessToken -Context $myGitHubContext -AsPlainText
        ```

        Output:
        ```powershell
        ghp_exampletoken1234567890
        ```

        Retrieves the access token from a specified context as a plain text string.

        .OUTPUTS
        System.Security.SecureString

        .OUTPUTS
        System.String

        .LINK
        https://psmodule.io/GitHub/Functions/Get-GitHubAccessToken/
    #>
    [OutputType([System.Security.SecureString], ParameterSetName = 'Get access token as SecureString')]
    [OutputType([System.String], ParameterSetName = 'Get access token as plain text')]
    [CmdletBinding(DefaultParameterSetName = 'Get access token as SecureString')]
    param(
        # If specified, the token will be returned as plain text.
        [Parameter(Mandatory, ParameterSetName = 'Get access token as plain text')]
        [switch] $AsPlainText,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
    }

    process {
        if ($AsPlainText) {
            return $Context.Token | ConvertFrom-SecureString -AsPlainText
        }

        return $Context.Token
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
