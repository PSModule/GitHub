filter Block-GitHubUser {
    <#
        .SYNOPSIS
        Block a user from user or an organization.

        .DESCRIPTION
        Blocks the given user and returns true.
        If the user cannot be blocked false is returned.

        .EXAMPLE
        Block-GitHubUser -Username 'octocat'

        Blocks the user 'octocat' for the authenticated user.
        Returns $true if successful, $false if not.

        .EXAMPLE
        Block-GitHubUser -Organization 'GitHub' -Username 'octocat'

        Blocks the user 'octocat' from the organization 'GitHub'.
        Returns $true if successful, $false if not.

        .NOTES
        [Block a user](https://docs.github.com/rest/users/blocking#block-a-user)
        [Block a user from an organization](https://docs.github.com/rest/orgs/blocking#block-a-user-from-an-organization)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Blocking/Block-GitHubUser
    #>
    [OutputType([bool])]
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory
        )]
        [Alias('login')]
        [string] $Username,

        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Organization'
        )]
        [Parameter(
            ParameterSetName = '__AllParameterSets'
        )]
        [string] $Organization,

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
            'Organization' {
                Block-GitHubUserByOrganization -Organization $Organization -Username $Username -Context $Context
            }
            '__AllParameterSets' {
                Block-GitHubUserByUser -Username $Username -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
