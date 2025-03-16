filter Get-GitHubEnvironment {
    <#
        .SYNOPSIS
        Retrieves details of a specified GitHub environment or lists all environments for a repository.

        .DESCRIPTION
        This function retrieves details of a specific environment in a GitHub repository when the `-Name` parameter
        is provided. Otherwise, it lists all available environments for the specified repository.

        Anyone with read access to the repository can use this function.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope
        to use this function with a private repository.

        .EXAMPLE
        Get-GitHubEnvironment -Owner "octocat" -Repository "Hello-World" -Name "production"

        Output:
        ```pwsh
        Name        : production
        URL         : https://github.com/octocat/Hello-World/environments/production
        Protection  : @{WaitTimer=0; Reviewers=@()}
        ```

        Retrieves details of the "production" environment in the specified repository.

        .EXAMPLE
        Get-GitHubEnvironment -Owner "octocat" -Repository "Hello-World"

        Output:
        ```pwsh
        Name         : production
        Protection   : @{required_reviewers=System.Object[]}
        ```

        Lists all environments available in the "Hello-World" repository owned by "octocat".

        .OUTPUTS
        PSCustomObject

        .NOTES
        Returns details of a GitHub environment or a list of environments for a repository.

        .LINK
        https://psmodule.io/GitHub/Functions/Environments/Get-GitHubEnvironment/
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        # The name of the organization.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the Repository.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Repository,

        # The name of the environment.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByName',
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

        # The maximum number of environments to return per request.
        [Parameter(ParameterSetName = 'List')]
        [ValidateRange(0, 100)]
        [int] $PerPage,

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
            'ByName' {
                Get-GitHubEnvironmentByName -Owner $Owner -Repository $Repository -Name $Name -Context $Context
            }
            'List' {
                Get-GitHubEnvironmentList -Owner $Owner -Repository $Repository -PerPage $PerPage -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
