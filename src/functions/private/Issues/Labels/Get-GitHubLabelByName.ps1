filter Get-GitHubLabelByName {
    <#
        .SYNOPSIS
        Get a label

        .DESCRIPTION
        Gets a label by name.

        .EXAMPLE
        Get-GitHubLabelByName -Owner 'octocat' -Repository 'hello-world' -Name 'bug' -Context $context

        Gets the label with the name 'bug' for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        None

        .OUTPUTS
        GitHubLabel

        .NOTES
        [Get a label](https://docs.github.com/rest/issues/labels#get-a-label)
    #>
    [OutputType([GitHubLabel])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The name of the label.
        [Parameter(Mandatory)]
        [string] $Name,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/labels/$([uri]::EscapeDataString($Name))"
            Context     = $Context
        }

        try {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                [GitHubLabel]::new($_.Response)
            }
        } catch {
            Write-Error $_.Exception.Message
            return
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
