﻿filter Remove-GitHubRelease {
    <#
        .SYNOPSIS
        Delete a release

        .DESCRIPTION
        Users with push access to the repository can delete a release.

        .EXAMPLE
        Remove-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -ID '1234567'

        Deletes the release with the ID '1234567' for the repository 'octocat/hello-world'.

        .NOTES
        [Delete a release](https://docs.github.com/rest/releases/releases#delete-a-release)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The unique identifier of the release.
        [Parameter(
            Mandatory
        )]
        [Alias('release_id')]
        [string] $ID,

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
        $inputObject = @{
            Method      = 'DELETE'
            APIEndpoint = "/repos/$Owner/$Repository/releases/$ID"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Release with ID [$ID] in [$Owner/$Repository]", 'DELETE')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
