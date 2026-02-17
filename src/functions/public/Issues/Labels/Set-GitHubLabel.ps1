filter Set-GitHubLabel {
    <#
        .SYNOPSIS
        Update a label

        .DESCRIPTION
        Updates a label for a repository.

        .EXAMPLE
        Set-GitHubLabel -Owner 'octocat' -Repository 'hello-world' -Name 'bug' -NewName 'defect'

        Renames the label 'bug' to 'defect' for the repository 'hello-world' owned by 'octocat'.

        .EXAMPLE
        Set-GitHubLabel -Owner 'octocat' -Repository 'hello-world' -Name 'bug' -Color 'ff0000' -Description 'Critical issue'

        Updates the color and description of the label 'bug' for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubLabel

        .OUTPUTS
        GitHubLabel

        .LINK
        https://psmodule.io/GitHub/Functions/Issues/Set-GitHubLabel/

        .NOTES
        [Update a label](https://docs.github.com/rest/issues/labels#update-a-label)
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

        # The current name of the label.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,

        # The new name of the label.
        [Parameter()]
        [string] $NewName,

        # The color of the label (hex code without #). Example: 'd73a4a'
        [Parameter()]
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
        if ($PSCmdlet.ShouldProcess("Label '$Name' in repository '$Owner/$Repository'", 'Update')) {
            $body = @{}

            if ($PSBoundParameters.ContainsKey('NewName')) {
                $body['new_name'] = $NewName
            }

            if ($PSBoundParameters.ContainsKey('Color')) {
                $body['color'] = $Color -replace '^#', ''
            }

            if ($PSBoundParameters.ContainsKey('Description')) {
                $body['description'] = $Description
            }

            $apiParams = @{
                Method      = 'PATCH'
                APIEndpoint = "/repos/$Owner/$Repository/labels/$([uri]::EscapeDataString($Name))"
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
