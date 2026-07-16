function Invoke-GitHubGraphQLConnectionPrefetch {
    <#
        .SYNOPSIS
        Prefetches paginated GraphQL connection nodes in a background runspace.

        .DESCRIPTION
        Uses a background runspace and a BlockingCollection queue to fetch pages from a GraphQL connection
        while the foreground pipeline emits previously fetched nodes.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Query,

        [Parameter()]
        [hashtable] $Variables = @{},

        [Parameter(Mandatory)]
        [string[]] $ConnectionPath,

        [Parameter(Mandatory)]
        [object] $Context,

        [Parameter()]
        [int] $QueueCapacity = 500
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        Update-GitHubUserAccessToken -Context $Context | Out-Null

        $apiBaseUri = Resolve-GitHubContextSetting -Name 'ApiBaseUri' -Context $Context
        $apiVersion = Resolve-GitHubContextSetting -Name 'ApiVersion' -Context $Context
        $endpoint = New-Uri -BaseUri $apiBaseUri -Path '/graphql' -AsString
        $token = $Context.Token | ConvertFrom-SecureString -AsPlainText

        $workerVariables = @{}
        foreach ($key in $Variables.Keys) {
            $workerVariables[$key] = $Variables[$key]
        }

        $queue = [System.Collections.Concurrent.BlockingCollection[object]]::new($QueueCapacity)
        $workerErrorQueue = [System.Collections.Concurrent.ConcurrentQueue[object]]::new()
        $cancellation = [System.Threading.CancellationTokenSource]::new()

        $workerRunspace = [runspacefactory]::CreateRunspace()
        $workerRunspace.Open()

        $workerPowerShell = [powershell]::Create()
        $workerPowerShell.Runspace = $workerRunspace

        $producerScript = {
            param(
                [System.Collections.Concurrent.BlockingCollection[object]] $Queue,
                [System.Collections.Concurrent.ConcurrentQueue[object]] $WorkerErrorQueue,
                [System.Threading.CancellationToken] $CancellationToken,
                [string] $Endpoint,
                [string] $ApiVersion,
                [string] $UserAgent,
                [string] $Token,
                [string] $Query,
                [hashtable] $Variables,
                [string[]] $ConnectionPath
            )

            try {
                $headers = @{
                    Accept                 = 'application/vnd.github+json; charset=utf-8'
                    'X-GitHub-Api-Version' = $ApiVersion
                    'User-Agent'           = $UserAgent
                    Authorization          = "Bearer $Token"
                }

                $hasNextPage = $true
                while ($hasNextPage -and -not $CancellationToken.IsCancellationRequested) {
                    $body = @{
                        query     = $Query
                        variables = $Variables
                    } | ConvertTo-Json -Depth 100

                    $response = Invoke-RestMethod -Uri $Endpoint -Method Post -Headers $headers -ContentType 'application/vnd.github+json; charset=utf-8' -Body $body -ErrorAction Stop

                    if ($response.errors) {
                        throw "GraphQL prefetch worker failed: $($response.errors | ConvertTo-Json -Depth 20 -Compress)"
                    }

                    $connection = $response.data
                    foreach ($segment in $ConnectionPath) {
                        if ($null -eq $connection) {
                            break
                        }

                        $connection = $connection.$segment
                    }

                    if ($null -eq $connection) {
                        throw "GraphQL prefetch worker could not resolve connection path: $($ConnectionPath -join '.')"
                    }

                    if ($null -ne $connection.nodes) {
                        foreach ($node in $connection.nodes) {
                            $Queue.Add($node, $CancellationToken)
                        }
                    }

                    $hasNextPage = [bool]$connection.pageInfo.hasNextPage
                    $Variables['Cursor'] = $connection.pageInfo.endCursor
                }
            } catch {
                $WorkerErrorQueue.Enqueue($_)
            } finally {
                $Queue.CompleteAdding()
            }
        }

        $null = $workerPowerShell.AddScript($producerScript.ToString()).
            AddArgument($queue).
            AddArgument($workerErrorQueue).
            AddArgument($cancellation.Token).
            AddArgument($endpoint).
            AddArgument($apiVersion).
            AddArgument($script:UserAgent).
            AddArgument($token).
            AddArgument($Query).
            AddArgument($workerVariables).
            AddArgument($ConnectionPath)

        $workerAsyncResult = $workerPowerShell.BeginInvoke()
        $completedNormally = $false

        try {
            foreach ($item in $queue.GetConsumingEnumerable()) {
                Write-Output $item
            }

            $workerPowerShell.EndInvoke($workerAsyncResult)

            $workerError = $null
            if ($workerErrorQueue.TryDequeue([ref]$workerError)) {
                throw $workerError
            }

            $completedNormally = $true
        } finally {
            if (-not $completedNormally) {
                $cancellation.Cancel()

                if (-not $queue.IsAddingCompleted) {
                    $queue.CompleteAdding()
                }

                try {
                    $workerPowerShell.Stop()
                } catch {
                }

                try {
                    if ($workerAsyncResult) {
                        $workerPowerShell.EndInvoke($workerAsyncResult)
                    }
                } catch {
                }
            }

            $workerPowerShell.Dispose()
            $workerRunspace.Dispose()
            $cancellation.Dispose()
            $queue.Dispose()
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}