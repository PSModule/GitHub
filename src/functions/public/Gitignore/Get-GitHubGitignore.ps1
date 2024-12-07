﻿#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }

filter Get-GitHubGitignore {
    <#
        .SYNOPSIS
        Get a gitignore template or list of all gitignore templates names

        .DESCRIPTION
        If no parameters are specified, the function will return a list of all gitignore templates names.
        If the Name parameter is specified, the function will return the gitignore template for the specified name.

        .EXAMPLE
        Get-GitHubGitignoreList

        Get all gitignore templates

        .EXAMPLE
        Get-GitHubGitignore -Name 'VisualStudio'

        Get a gitignore template for VisualStudio

        .NOTES
        [Get a gitignore template](https://docs.github.com/rest/gitignore/gitignore#get-a-gitignore-template)
        [Get all gitignore templates](https://docs.github.com/rest/gitignore/gitignore#get-all-gitignore-templates)

    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
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
            ValidateSet            = Get-GitHubGitignoreList
            DynamicParamDictionary = $DynamicParamDictionary
        }
        New-DynamicParam @dynParam

        return $DynamicParamDictionary
    }

    begin {
        $Context = Resolve-GitHubContext -Context $Context
    }

    process {
        $Name = $PSBoundParameters['Name']
        switch ($PSCmdlet.ParameterSetName) {
            'List' {
                Get-GitHubGitignoreList -Context $Context
            }
            'Name' {
                Get-GitHubGitignoreByName -Name $Name -Context $Context
            }
        }
    }
}
