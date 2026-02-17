filter Remove-GitHubLabel {
    <#
        .SYNOPSIS
        Delete a label

        .DESCRIPTION
        Deletes a label from a repository.

        .EXAMPLE
        Remove-GitHubLabel -Owner 'octocat' -Repository 'hello-world' -Name 'bug'

        Deletes the label with the name 'bug' from the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubLabel

        .OUTPUTS
        None

        .LINK
        https://psmodule.io/GitHub/Functions/Issues/Remove-GitHubLabel/

        .NOTES
        [Delete a label](https://docs.github.com/rest/issues/labels#delete-a-label)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the label to delete.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,

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
        if ($PSCmdlet.ShouldProcess("Label '$Name' in repository '$Owner/$Repository'", 'Delete')) {
            $apiParams = @{
                Method      = 'DELETE'
                APIEndpoint = "/repos/$Owner/$Repository/labels/$([uri]::EscapeDataString($Name))"
                Context     = $Context
            }

            Invoke-GitHubAPI @apiParams | Out-Null
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
