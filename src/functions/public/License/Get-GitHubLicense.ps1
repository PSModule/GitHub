filter Get-GitHubLicense {
    <#
        .SYNOPSIS
        Get a license template, list of all popular license templates or a license for a repository

        .DESCRIPTION
        If no parameters are specified, the function will return a list of all license templates.
        If the Name parameter is specified, the function will return the license template for the specified name.
        If the Owner and Repo parameters are specified, the function will return the license for the specified repository.

        .EXAMPLE
        Get-GitHubLicense

        Get all license templates

        .EXAMPLE
        Get-GitHubLicense -Name mit

        Get the mit license template

        .EXAMPLE
        Get-GitHubLicense -Owner 'octocat' -Repository 'Hello-World'

        Get the license for the Hello-World repository from the octocat account.

        .PARAMETER Name
        The license keyword, license name, or license SPDX ID. For example, mit or mpl-2.0.

        .NOTES
        [Get a license](https://docs.github.com/rest/licenses/licenses#get-a-license)
        [Get all commonly used licenses](https://docs.github.com/rest/licenses/licenses#get-all-commonly-used-licenses)
        [Get the license for a repository](https://docs.github.com/rest/licenses/licenses#get-the-license-for-a-repository)
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Repository')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Repository')]
        [string] $Repository,

        # The license keyword, license name, or license SPDX ID. For example, mit or mpl-2.0.
        [Parameter(ParameterSetName = 'Name')]
        [string] $Name,

        # If specified, makes an anonymous request to the GitHub API without authentication.
        [Parameter()]
        [switch] $Anonymous,

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
        $params = @{
            Anonymous = $Anonymous
            Context   = $Context
        }
        switch ($PSCmdlet.ParameterSetName) {
            'List' {
                Get-GitHubLicenseList @params
            }
            'Name' {
                Get-GitHubLicenseByName @params -Name $Name
            }
            'Repository' {
                Get-GitHubRepositoryLicense @params -Owner $Owner -Repository $Repository
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

Register-ArgumentCompleter -CommandName Get-GitHubLicense -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter
    Get-GitHubLicense -Anonymous | Select-Object -ExpandProperty Name | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
