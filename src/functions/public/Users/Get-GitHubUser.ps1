filter Get-GitHubUser {
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
        Get-GitHubUser -Username 'octocat'

        Get the 'octocat' user.

        .EXAMPLE
        Get-GitHubUser -All -Since 17722253

        Get a list of users, starting with the user 'MariusStorhaug'.

        .NOTES
        [Get the authenticated user](https://docs.github.com/rest/users/users)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser', SupportsPaging)]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ParameterSetName = 'NamedUser',
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

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
        $irmParams = @{
            APIEndpoint = switch ($PSCmdlet.ParameterSetName) {
                'AuthenticatedUser' {
                    '/user'
                }
                'NamedUser' {
                    "/users/$Username"
                }
                'AllUsers' {
                    '/users'
                }
            }
            Context     = $Context
            Method      = 'GET'
        }
        if ($PScmdlet.ParameterSetName -eq 'AllUsers') {
            $irmParams['QueryParameters'] = @{
                since    = $Since
                per_page = $PerPage
            }
            foreach ($_name in 'First', 'Skip') {
                if ($PSBoundParameters.ContainsKey($_name)) {
                    $irmParams[$_name] = $_name
                }
            }
            Invoke-GitHubRestMethod @irmParams
        }
        else {
            $user = Invoke-GitHubRestMethod @irmParams
            $getSocialParams = @{
                Context = $Context
            }
            if (-not [string]::IsNullOrWhiteSpace($Username)) {
                $getSocialParams['Username'] = $Username
            }
            $social_accounts = Get-GitHubUserSocialAccount @getSocialParams
            $user | Add-Member -MemberType NoteProperty -Name 'social_accounts' -Value $social_accounts -Force -PassThru
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
