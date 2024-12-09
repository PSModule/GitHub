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
        [Parameter(ValueFromPipeline)]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        Write-Verbose 'Context:'
        $Context | Format-Table | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
    }

    process {
        if ($Context -is [string]) {
            $contextName = $Context
            Write-Verbose "Getting context: [$contextName]"
            $Context = Get-GitHubContext -Context $contextName
        }

        if (-not $Context) {
            throw "Context [$contextName] not found. Please provide a valid context or log in using 'Connect-GitHub'."
        }

        # switch ($Context.Type) {
        #     'App' {
        #         $availableContexts = Get-GitHubContext -ListAvailable |
        #             Where-Object { $_.Type -eq 'Installation' -and $_.ClientID -eq $Context.ClientID }
        #         $params = Get-FunctionParameter -Scope 2
        #         Write-Verbose 'Resolving parameters used in called function'
        #         Write-Verbose ($params | Out-String)
        #         if ($params.Keys -in 'Owner', 'Organization') {
        #             $Context = $availableContexts | Where-Object { $_.Owner -eq $params.Owner }
        #         }
        #     }
        # }

        Write-Verbose 'Resolved Context:'
        $Context | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
    }

    end {
        Write-Verbose "[$commandName] - End"
        Write-Output $Context
    }
}
