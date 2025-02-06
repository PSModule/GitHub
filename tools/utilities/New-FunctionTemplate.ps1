function New-GitHubFunctionTemplate {
    <#
        .SYNOPSIS
        Short description

        .DESCRIPTION
        Long description

        .EXAMPLE
        An example

        .NOTES
        [Ttle](link)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the organization.
        [Parameter()]
        [string] $Owner,

        # The name of the organization.
        [Parameter()]
        [string] $Repo,

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
        "<logic here>"
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
