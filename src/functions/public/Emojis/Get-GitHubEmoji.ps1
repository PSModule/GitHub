filter Get-GitHubEmoji {
    <#
        .SYNOPSIS
        Get emojis

        .DESCRIPTION
        Lists all the emojis available to use on GitHub.
        If you pass the `Destination` parameter, the emojis will be downloaded to the specified destination.

        .EXAMPLE
        Get-GitHubEmoji

        Gets all the emojis available to use on GitHub.

        .EXAMPLE
        Get-GitHubEmoji -Destination 'C:\Users\user\Documents\GitHub\Emojis'

        Downloads all the emojis available to use on GitHub to the specified destination.

        .NOTES
        [Get emojis](https://docs.github.com/rest/reference/emojis#get-emojis)
    #>
    [CmdletBinding()]
    param(
        # The path to the directory where the emojis will be downloaded.
        [Parameter()]
        [string] $Destination,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/emojis'
                Method      = 'GET'
            }

            $response = Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }

            if (Test-Path -Path $Destination) {
                $response.PSObject.Properties | ForEach-Object -ThrottleLimit ([System.Environment]::ProcessorCount) -Parallel {
                    Invoke-WebRequest -Uri $_.Value -OutFile "$using:Destination/$($_.Name).png"
                }
            } else {
                $response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
