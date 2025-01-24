filter Set-GitHubReleaseAsset {
    <#
        .SYNOPSIS
        Update a release asset

        .DESCRIPTION
        Users with push access to the repository can edit a release asset.

        .EXAMPLE
        Set-GitHubReleaseAsset -Owner 'octocat' -Repo 'hello-world' -ID '1234567' -Name 'new_asset_name' -Label 'new_asset_label'

        Updates the release asset with the ID '1234567' for the repository 'octocat/hello-world' with the new name 'new_asset_name' and
        label 'new_asset_label'.

        .NOTES
        [Update a release asset](https://docs.github.com/rest/releases/assets#update-a-release-asset)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The unique identifier of the asset.
        [Parameter(Mandatory)]
        [Alias('asset_id')]
        [string] $ID,

        #The name of the file asset.
        [Parameter()]
        [string] $Name,

        # An alternate short description of the asset. Used in place of the filename.
        [Parameter()]
        [string] $Label,

        # State of the release asset.
        [Parameter()]
        [ValidateSet('uploaded', 'open')]
        [string] $State,

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

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo: [$Repo]"
    }

    process {
        try {
            $body = @{
                name  = $Name
                label = $Label
                state = $State
            }
            $body | Remove-HashtableEntry -NullOrEmptyValues

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/releases/assets/$ID"
                Method      = 'PATCH'
                Body        = $body
            }

            if ($PSCmdlet.ShouldProcess("assets for release with ID [$ID] in [$Owner/$Repo]", 'Set')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
