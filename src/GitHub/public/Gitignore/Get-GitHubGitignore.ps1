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
        https://docs.github.com/rest/gitignore/gitignore#get-a-gitignore-template
        https://docs.github.com/rest/gitignore/gitignore#get-all-gitignore-templates

    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param ()

    DynamicParam {
        $runtimeDefinedParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        $parameterName = 'Name'
        $parameterType = [string]
        $parameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $parameterAttribute.ParameterSetName = 'Name'
        $parameterAttribute.Mandatory = $true
        $attributeCollection.Add($parameterAttribute)

        $parameterValidateSet = Get-GitHubGitignoreList
        $validateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($parameterValidateSet)
        $attributeCollection.Add($validateSetAttribute)

        $runtimeDefinedParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($parameterName, $parameterType, $attributeCollection)
        $runtimeDefinedParameterDictionary.Add($parameterName, $runtimeDefinedParameter)

        return $runtimeDefinedParameterDictionary
    }

    Process {
        $Name = $PSBoundParameters['Name']
        switch ($PSCmdlet.ParameterSetName) {
            'List' {
                Get-GitHubGitignoreList
            }
            'Name' {
                Get-GitHubGitignoreByName -Name $Name
            }
        }
    }
}
