function Get-GitHubEnterprise {
    <#
        .SYNOPSIS
        Retrieves GitHub Enterprise instance details for the authenticated user.

        .DESCRIPTION
        Retrieves detailed information about GitHub Enterprise instances available to the authenticated user.
        By default, the command lists all accessible instances, including metadata such as the enterprise name, slug, URL, and creation date. If a
        specific enterprise name is provided, details about that single instance are returned.

        .EXAMPLE
        Get-GitHubEnterprise

        Output:
        ```powershell
        Name              : My Enterprise
        Slug              : my-enterprise
        URL               : https://github.com/enterprises/my-enterprise
        CreatedAt         : 2022-01-01T00:00:00Z

        Name              : Another Enterprise
        Slug              : another-enterprise
        URL               : https://github.com/enterprises/another-enterprise
        CreatedAt         : 2022-01-01T00:00:00Z
        ```

        Retrieves details about all GitHub Enterprise instances for the user.

        .EXAMPLE
        Get-GitHubEnterprise -Name 'my-enterprise'

        Output:
        ```powershell
        Name              : My Enterprise
        Slug              : my-enterprise
        URL               : https://github.com/enterprises/my-enterprise
        CreatedAt         : 2022-01-01T00:00:00Z
        ```

        Retrieves details about the GitHub Enterprise instance named 'my-enterprise'.

        .OUTPUTS
        GitHubEnterprise

        .NOTES
        An object containing detailed information about the GitHub Enterprise instance, including billing info, URLs, and metadata.

        .LINK
        https://psmodule.io/GitHub/Functions/Enterprise/Get-GitHubEnterprise/
    #>
    [OutputType([GitHubEnterprise])]
    [CmdletBinding(DefaultParameterSetName = 'List enterprises for the authenticated user')]
    param(
        # The name (slug) of the GitHub Enterprise instance to retrieve.
        [Parameter(Mandatory, ParameterSetName = 'Get enterprise by name')]
        [Alias('Slug')]
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
        switch ($PSCmdlet.ParameterSetName) {
            'Get enterprise by name' {
                Get-GitHubEnterpriseByName -Name $Name -Context $Context
                break
            }
            default {
                Get-GitHubEnterpriseList -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
