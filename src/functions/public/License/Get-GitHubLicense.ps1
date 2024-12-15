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
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Repository')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Repository')]
        [string] $Repo,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
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

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner : [$($Context.Owner)]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo : [$($Context.Repo)]"
    }

    process {
        try {
            $Name = $PSBoundParameters['Name']
            switch ($PSCmdlet.ParameterSetName) {
                'List' {
                    Get-GitHubLicenseList -Context $Context
                }
                'Name' {
                    Get-GitHubLicenseByName -Name $Name -Context $Context
                }
                'Repository' {
                    Get-GitHubRepositoryLicense -Owner $Owner -Repo $Repo -Context $Context
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
