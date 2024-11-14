#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }

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
        Get-GitHubLicense -Owner 'octocat' -Repo 'Hello-World'

        Get the license for the Hello-World repository from the octocat account.

        .PARAMETER Name
        The license keyword, license name, or license SPDX ID. For example, mit or mpl-2.0.

        .NOTES
        [Get a license](https://docs.github.com/rest/licenses/licenses#get-a-license)
        [Get all commonly used licenses](https://docs.github.com/rest/licenses/licenses#get-all-commonly-used-licenses)
        [Get the license for a repository](https://docs.github.com/rest/licenses/licenses#get-the-license-for-a-repository)

    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Repository')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Repository')]
        [string] $Repo = (Get-GitHubConfig -Name Repo)
    )

    dynamicparam {
        $DynamicParamDictionary = New-DynamicParamDictionary

        $dynParam = @{
            Name                   = 'Name'
            ParameterSetName       = 'Name'
            Type                   = [string]
            Mandatory              = $true
            ValidateSet            = Get-GitHubLicenseList | Select-Object -ExpandProperty Name
            DynamicParamDictionary = $DynamicParamDictionary
        }
        New-DynamicParam @dynParam

        return $DynamicParamDictionary
    }

    process {
        $Name = $PSBoundParameters['Name']
        switch ($PSCmdlet.ParameterSetName) {
            'List' {
                Get-GitHubLicenseList
            }
            'Name' {
                Get-GitHubLicenseByName -Name $Name
            }
            'Repository' {
                Get-GitHubRepositoryLicense -Owner $Owner -Repo $Repo
            }
        }
    }
}
