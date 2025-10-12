filter Connect-GitHubCli {
    <#
        .SYNOPSIS
        Authenticates to GitHub CLI using a secure token from the provided context.

        .DESCRIPTION
        This function takes an input context containing authentication details and logs into GitHub CLI (`gh auth login`).
        It extracts the token from the provided context and passes it securely to the authentication command.
        If authentication fails, a warning is displayed, and `LASTEXITCODE` is reset to `0`.

        .EXAMPLE
        ```powershell
        $context = Connect-GitHubAccount
        $context | Connect-GitHubCli
        ```

        Output:
        ```powershell
        (No output unless an error occurs)
        ```

        Logs into GitHub CLI using the provided authentication token and hostname from the context.

        .OUTPUTS
        void

        .NOTES
        The function does not return any output. It logs into GitHub CLI using the provided context.
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # The context to run the command in.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $return = ($Context.Token | ConvertFrom-SecureString -AsPlainText | gh auth login --with-token --hostname $Context.HostName) 2>&1
        $return = $return -join [System.Environment]::NewLine
        if ($LASTEXITCODE -ne 0) {
            if ($return.Contains('GITHUB_TOKEN environment variable is being used for authentication')) {
                Write-Debug $return
            } else {
                Write-Warning "Unable to log on with the GitHub Cli. ($LASTEXITCODE)"
                Write-Warning "$($return)"
            }
            $Global:LASTEXITCODE = 0
            Write-Debug "Resetting LASTEXITCODE: $LASTEXITCODE"
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
