filter Get-GitHubGitignore {
    <#
        .SYNOPSIS
        Get a gitignore template or list of all gitignore templates names

        .DESCRIPTION
        If no parameters are specified, the function will return a list of all gitignore templates names.
        If the Name parameter is specified, the function will return the gitignore template for the specified name.

        .EXAMPLE
        ```powershell
        Get-GitHubGitignoreList
        ```

        Get all gitignore templates

        .EXAMPLE
        ```powershell
        Get-GitHubGitignore -Name 'VisualStudio'
        ```

        Get a gitignore template for VisualStudio

        .NOTES
        [Get a gitignore template](https://docs.github.com/rest/gitignore/gitignore#get-a-gitignore-template)
        [Get all gitignore templates](https://docs.github.com/rest/gitignore/gitignore#get-all-gitignore-templates)

        .LINK
        https://psmodule.io/GitHub/Functions/Gitignore/Get-GitHubGitignore
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(
            Mandatory,
            ParameterSetName = 'Name'
        )]
        [string] $Name,

        # If specified, makes an anonymous request to the GitHub API without authentication.
        [Parameter()]
        [switch] $Anonymous,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context -Anonymous $Anonymous
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT, Anonymous
    }

    process {
        $params = @{
            Context   = $Context
        }
        switch ($PSCmdlet.ParameterSetName) {
            'List' {
                Get-GitHubGitignoreList @params
            }
            'Name' {
                Get-GitHubGitignoreByName @params -Name $Name
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
