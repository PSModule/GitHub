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
        [Parameter(
            Mandatory,
            ParameterSetName = 'Name'
        )]
        [string] $Name,

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
        switch ($PSCmdlet.ParameterSetName) {
            'List' {
                Get-GitHubGitignoreList -Context $Context
            }
            'Name' {
                Get-GitHubGitignoreByName -Name $Name -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

Register-ArgumentCompleter -CommandName Get-GitHubGitignore -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter
    Get-GitHubGitignore | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
