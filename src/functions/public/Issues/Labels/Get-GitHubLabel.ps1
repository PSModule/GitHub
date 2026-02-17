filter Get-GitHubLabel {
    <#
        .SYNOPSIS
        Get labels for a repository

        .DESCRIPTION
        Lists all labels for a repository or gets a single label by name.

        .EXAMPLE
        Get-GitHubLabel -Owner 'octocat' -Repository 'hello-world'

        Lists all labels for the repository 'hello-world' owned by 'octocat'.

        .EXAMPLE
        Get-GitHubLabel -Owner 'octocat' -Repository 'hello-world' -Name 'bug'

        Gets the label with the name 'bug' for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubLabel

        .LINK
        https://psmodule.io/GitHub/Functions/Issues/Get-GitHubLabel/
    #>
    [OutputType([GitHubLabel])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the label to get. If not specified, all labels will be listed.
        [Parameter()]
        [string] $Name,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $params = @{
            Owner      = $Owner
            Repository = $Repository
            Context    = $Context
        }

        if ($Name) {
            Get-GitHubLabelByName @params -Name $Name
        } else {
            Get-GitHubLabelList @params -PerPage $PerPage
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
