filter Remove-GitHubRelease {
    <#
        .SYNOPSIS
        Delete a release

        .DESCRIPTION
        Users with push access to the repository can delete a release.

        .EXAMPLE
        Remove-GitHubRelease -Owner 'octocat' -Repository 'hello-world' -ID '1234567'

        Deletes the release with the ID '1234567' for the repository 'octocat/hello-world'.

        .INPUTS
        GitHubRelease

        .OUTPUTS
        None

        .LINK
        https://psmodule.io/GitHub/Functions/Releases/Remove-GitHubRelease/

        .NOTES
        [Delete a release](https://docs.github.com/rest/releases/releases#delete-a-release)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The unique identifier of the release.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
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

        if ($PSCmdlet.ShouldProcess("Release with ID [$ID] in [$Owner/$Repository]", 'Delete')) {
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
