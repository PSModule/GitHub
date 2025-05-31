function Invoke-ConcurrentScript {
    <#
        .SYNOPSIS
        Executes a script block with mutex-based concurrency control

        .DESCRIPTION
        Executes a script block while ensuring only one instance runs at a time by using a named mutex.
        This function provides a way to safely execute code that should not run concurrently across
        multiple PowerShell sessions or processes. If the mutex cannot be acquired within the specified
        timeout period, the script block will not be executed.

        .EXAMPLE
        Invoke-ConcurrentScript -Name 'Global\Demo' -ScriptBlock {
            Write-Host "$(Get-Date -Format HH:mm:ss) - Doing critical work..."
            Start-Sleep -Seconds 5
        }

        Executes the script block with a mutex named 'Global\Demo', ensuring only one instance
        of this code runs at a time across all processes.

        .EXAMPLE
        Invoke-ConcurrentScript -Name 'MyProcess' -Timeout 100 -ScriptBlock {
            # Critical section code that should not run concurrently
            Update-SharedResource -Path 'C:\SharedData\file.txt'
        }

        Executes the script with a timeout of 100ms for mutex acquisition, preventing
        concurrent access to the shared resource.

        .NOTES
        Mutex names are case-sensitive and can be prefixed with 'Global\' to make them visible
        across user sessions. Invalid characters in mutex names are automatically replaced with '_'.

        If a process terminates without releasing the mutex, it will be considered abandoned,
        and the next process trying to acquire it will receive an AbandonedMutexException,
        which this function handles gracefully.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        # The name for the concurrent script execution context.
        [Parameter(Mandatory)]
        [string] $Name,

        # Timeout in milliseconds before checking if any other process is running.
        [Parameter()]
        [int] $Timeout = 1,

        # The script block to execute concurrently.
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Name = $Name -replace '[\\/:*?"<>|]', '_'
        $mutex = [System.Threading.Mutex]::new($false, $Name)
    }

    process {
        try {
            Write-Debug "$(Get-Date -Format HH:mm:ss) - [$PID] Waiting to acquire mutex '$Name' (timeout: $Timeout ms)..."
            try {
                if ($mutex.WaitOne($Timeout)) {
                    Write-Debug "$(Get-Date -Format HH:mm:ss) - [$PID] Mutex acquired!"
                    & $ScriptBlock
                    Write-Debug "$(Get-Date -Format HH:mm:ss) - [$PID] Work completed. Releasing mutex."
                    $mutex.ReleaseMutex()
                } else {
                    Write-Debug "$(Get-Date -Format HH:mm:ss) - [$PID] Failed to acquire mutex within timeout ($Timeout ms)."
                }
            } catch [System.Threading.AbandonedMutexException] {
                Write-Debug "$(Get-Date -Format HH:mm:ss) - [$PID] Mutex abandoned by previous owner. Proceeding carefully."
                & $ScriptBlock
                Write-Debug "$(Get-Date -Format HH:mm:ss) - [$PID] Work completed after abandoned mutex. Releasing mutex."
                $mutex.ReleaseMutex()
            }
        } finally {
            $mutex.Dispose()
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
