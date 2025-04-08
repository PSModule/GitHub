filter Get-GitHubMyUser {
    <#
        .SYNOPSIS
        Get the authenticated user

        .DESCRIPTION
        If the authenticated user is authenticated with an OAuth token with the `user` scope, then the response lists public
        and private profile information.
        If the authenticated user is authenticated through OAuth without the `user` scope, then the response lists only public
        profile information.

        .EXAMPLE
        Get-GitHubMyUser

        Get the authenticated user

        .OUTPUTS
        GitHubUser

        .LINK
        [Get the authenticated user](https://docs.github.com/rest/users/users#get-the-authenticated-user)
    #>
    [OutputType([GitHubUser])]
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = '/user'
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            [GitHubUser]@{
                Name              = $_.Response.login
                ID                = $_.Response.id
                NodeID            = $_.Response.node_id
                AvatarUrl         = $_.Response.avatar_url
                Url               = $_.Response.html_url
                Type              = $_.Response.type
                UserViewType      = $_.Response.user_view_type
                DisplayName       = $_.Response.name
                Company           = $_.Response.company
                Blog              = $_.Response.blog
                Location          = $_.Response.location
                Email             = $_.Response.email
                Hireable          = $_.Response.hireable
                Bio               = $_.Response.bio
                TwitterUsername   = $_.Response.twitter_username
                NotificationEmail = $_.Response.notification_email
                PublicRepos       = $_.Response.public_repos
                PublicGists       = $_.Response.public_gists
                Followers         = $_.Response.followers
                Following         = $_.Response.following
                CreatedAt         = $_.Response.created_at
                UpdatedAt         = $_.Response.updated_at
                Plan              = [GitHubPlan]@{
                    Name          = $_.Response.plan.name
                    Space         = $_.Response.plan.space
                    Collaborators = $_.Response.plan.collaborators
                    PrivateRepos  = $_.Response.plan.private_repos
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
