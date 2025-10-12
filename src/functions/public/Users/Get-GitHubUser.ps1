function Get-GitHubUser {
    <#
        .SYNOPSIS
        List user(s)

        .DESCRIPTION
        Get the authenticated user - if no parameters are provided.
        Get a given user - if a username is provided.
        Lists all users, in the order that they signed up on GitHub - if '-All' is provided.

        .EXAMPLE
        ```pwsh
        Get-GitHubUser
        ```

        Get the authenticated user.

        .EXAMPLE
        ```pwsh
        Get-GitHubUser -Name 'octocat'
        ```

        Get the 'octocat' user.

        .EXAMPLE
        ```pwsh
        Get-GitHubUser -All -Since 17722253
        ```

        Get a list of users, starting with the user 'MariusStorhaug'.

        .OUTPUTS
        GitHubOwner

        .NOTES
        [Get the authenticated user](https://docs.github.com/rest/users/users)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Get-GitHubUser
    #>
    [OutputType([GitHubOwner])]
    [Alias('Get-GitHubOwner')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSReviewUnusedParameter', 'All',
        Justification = 'Parameter is used in dynamic parameter validation.'
    )]
    [CmdletBinding(DefaultParameterSetName = 'Authenticated user')]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ParameterSetName = 'By name',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

        # List all users. Use '-Since' to start at a specific user ID.
        [Parameter(
            Mandatory,
            ParameterSetName = 'All users'
        )]
        [switch] $All,

        # A user ID. Only return users with an ID greater than this ID.
        [Parameter(ParameterSetName = 'All users')]
        [int] $Since = 0,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'All users')]
        [System.Nullable[int]] $PerPage,

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
            'By name' {
                Get-GitHubUserByName -Name $Name -Context $Context
            }
            'All users' {
                Get-GitHubAllUser -Since $Since -PerPage $PerPage -Context $Context
            }
            default {
                Get-GitHubMyUser -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
