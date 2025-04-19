filter Get-GitHubEmoji {
    <#
        .SYNOPSIS
        Get emojis

        .DESCRIPTION
        Lists all the emojis available to use on GitHub.
        If you pass the `Path` parameter, the emojis will be downloaded to the specified destination.

        .EXAMPLE
        Get-GitHubEmoji

        Gets all the emojis available to use on GitHub.

        .EXAMPLE
        Get-GitHubEmoji -Path 'C:\Users\user\Documents\GitHub\Emojis'

        Downloads all the emojis available to use on GitHub to the specified destination.

        .NOTES
        [Get emojis](https://docs.github.com/rest/reference/emojis#get-emojis)
    #>
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The path to the directory where the emojis will be downloaded.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Download'
        )]
        [string] $Path,

        # If specified, makes an anonymous request to the GitHub API without authentication.
        [Parameter()]
        [switch] $Anonymous,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT, Anonymous
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = '/emojis'
            Anonymous   = $Anonymous
            Context     = $Context
        }

        $response = Invoke-GitHubAPI @inputObject | Select-Object -ExpandProperty Response

        switch ($PSCmdlet.ParameterSetName) {
            'Download' {
                $failedEmojis = @()
                if (-not (Test-Path -Path $Path)) {
                    $null = New-Item -Path $Path -ItemType Directory -Force
                }
                $failedEmojis = $response.PSObject.Properties | ForEach-Object -ThrottleLimit ([System.Environment]::ProcessorCount) -Parallel {
                    $emoji = $_
                    Write-Verbose "Downloading [$($emoji.Name).png] from [$($emoji.Value)] -> [$using:Path/$($emoji.Name).png]"
                    try {
                        Invoke-WebRequest -Uri $emoji.Value -OutFile "$using:Path/$($emoji.Name).png" -RetryIntervalSec 1 -MaximumRetryCount 5
                    } catch {
                        Write-Warning "Could not download [$($emoji.Name).png] from [$($emoji.Value)] -> [$using:Path/$($emoji.Name).png]"
                    }
                }
                if ($failedEmojis.Count -gt 0) {
                    Write-Warning 'Failed to download the following emojis:'
                    $failedEmojis | Out-String -Stream | ForEach-Object { Write-Warning $_ }
                }
            }
            default {
                $response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
