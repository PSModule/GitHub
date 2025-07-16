filter Resolve-GitHubContext {
    <#
        .SYNOPSIS
        Resolves the context into a GitHubContext object.

        .DESCRIPTION
        This function resolves the context into a GitHubContext object.
        If the context is already a GitHubContext object, it will return the object.
        If the context is a string, it will get the context details and return a GitHubContext object.

        If the context is a App, it will look at the available contexts and return the one that matches the scope of the command being run.

        .EXAMPLE
        $Context = Resolve-GitHubContext -Context 'github.com/Octocat'

        This will resolve the context 'github.com/Octocat' into a GitHubContext object.

        .EXAMPLE
        $Context = Resolve-GitHubContext -Context $GitHubContext

        This will return the GitHubContext object.
    #>
    [OutputType([GitHubContext])]
    [CmdletBinding()]
    param(
        # The context to resolve into an object. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [object] $Context,

        # If specified, makes an anonymous request to the GitHub API without authentication.
        [Parameter()]
        [bool] $Anonymous
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Initialize-GitHubConfig
    }

    process {
        Write-Verbose "Context: [$Context]"
        Write-Verbose "Anonymous: [$Anonymous]"
        if ($Anonymous -or $Context -eq 'Anonymous') {
            Write-Verbose 'Returning Anonymous context.'
            return [GitHubContext]::new(
                [pscustomobject]@{
                    Name     = 'Anonymous'
                    AuthType = 'Anonymous'
                }
            )
        }

        if ($Context -is [string]) {
            $contextName = $Context
            Write-Verbose "Getting context: [$contextName]"
            $Context = Get-GitHubContext -Context $contextName
        }

        if ($null -eq $Context) {
            Write-Verbose 'Context is null, returning default context.'
            $Context = Get-GitHubContext
        }

        switch ($Context.TokenType) {
            'ghu' {
                Write-Verbose 'Update GitHub User Access Token.'
                $Context = Update-GitHubUserAccessToken -Context $Context -PassThru
            }
            'JWT' {
                Write-Verbose 'Update GitHub App JWT Token.'
                $Context = Update-GitHubAppJWT -Context $Context -PassThru
            }
        }

        # TODO: Implement App installation context resolution
        # switch ($Context.Type) {
        #     'App' {
        #         $availableContexts = Get-GitHubContext -ListAvailable |
        #             Where-Object { $_.Type -eq 'Installation' -and $_.ClientID -eq $Context.ClientID }
        #         $params = Get-FunctionParameter -Scope 2
        #         Write-Debug 'Resolving parameters used in called function'
        #         Write-Debug ($params | Out-String)
        #         if ($params.Keys -in 'Owner', 'Organization') {
        #             $Context = $availableContexts | Where-Object { $_.Owner -eq $params.Owner }
        #         }
        #     }
        # }

        $Context
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
