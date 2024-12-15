filter Get-GitHubOctocat {
    <#
        .SYNOPSIS
        Get Octocat.

        .DESCRIPTION
        Get the octocat as ASCII art.

        .EXAMPLE
        Get-GitHubOctocat

        Get the octocat as ASCII art

        .EXAMPLE
        Get-GitHubOctocat -S "Hello world"

        Get the octocat as ASCII art with a custom saying

        .NOTES
        [Get Octocat](https://docs.github.com/rest/meta/meta#get-octocat)
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The words to show in Octocat's speech bubble
        [Parameter()]
        [Alias('Say')]
        [Alias('Saying')]
        [string] $S,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $body = @{
                s = $S
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/octocat'
                Method      = 'GET'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
