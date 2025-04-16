function Get-GitHubUser {
    <#
        .SYNOPSIS
        List user(s)

        .DESCRIPTION
        Get the authenticated user - if no parameters are provided.
        Get a given user - if a username is provided.
        Lists all users, in the order that they signed up on GitHub - if '-All' is provided.

        .EXAMPLE
        Get-GitHubUser

        Get the authenticated user.

        .EXAMPLE
        Get-GitHubUser -Name 'octocat'

        Get the 'octocat' user.

        .EXAMPLE
        Get-GitHubUser -All -Since 17722253

        Get a list of users, starting with the user 'MariusStorhaug'.

        .OUTPUTS
        GitHubUser

        .NOTES
        [Get the authenticated user](https://docs.github.com/rest/users/users)
    #>
    [OutputType([GitHubUser])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSReviewUnusedParameter', 'All',
        Justification = 'Parameter is used in dynamic parameter validation.'
    )]
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByName',
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

        # List all users. Use '-Since' to start at a specific user ID.
        [Parameter(
            Mandatory,
            ParameterSetName = 'AllUsers'
        )]
        [switch] $All,

        # A user ID. Only return users with an ID greater than this ID.
        [Parameter(ParameterSetName = 'AllUsers')]
        [int] $Since = 0,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'AllUsers')]
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
                Get-GitHubUserByName -Name $Name -Context $Context
            }
            'AllUsers' {
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
