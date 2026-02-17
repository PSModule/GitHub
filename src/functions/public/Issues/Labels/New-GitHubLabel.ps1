filter New-GitHubLabel {
    <#
        .SYNOPSIS
        Create a label

        .DESCRIPTION
        Creates a label for a repository.

        .EXAMPLE
        New-GitHubLabel -Owner 'octocat' -Repository 'hello-world' -Name 'bug' -Color 'd73a4a' -Description 'Something is not working'

        Creates a label with the name 'bug' for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubLabel

        .LINK
        https://psmodule.io/GitHub/Functions/Issues/New-GitHubLabel/

        .NOTES
        [Create a label](https://docs.github.com/rest/issues/labels#create-a-label)
    #>
    [OutputType([GitHubLabel])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the label.
        [Parameter(Mandatory)]
        [string] $Name,

        # The color of the label (hex code without #). Example: 'd73a4a'
        [Parameter(Mandatory)]
        [string] $Color,

        # A short description of the label.
        [Parameter()]
        [string] $Description,

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
        if ($PSCmdlet.ShouldProcess("Label '$Name' in repository '$Owner/$Repository'", 'Create')) {
            $body = @{
                name  = $Name
                color = $Color -replace '^#', ''
            }

            if ($PSBoundParameters.ContainsKey('Description')) {
                $body['description'] = $Description
            }

            $apiParams = @{
                Method      = 'POST'
                APIEndpoint = "/repos/$Owner/$Repository/labels"
                Body        = $body
                Context     = $Context
            }

            Invoke-GitHubAPI @apiParams | ForEach-Object {
                [GitHubLabel]::new($_.Response)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
