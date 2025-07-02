filter Get-GitHubUserByName {
    <#
        .SYNOPSIS
        Get a user

        .DESCRIPTION
        Provides publicly available information about someone with a GitHub account.
        GitHub Apps with the `Plan` user permission can use this endpoint to retrieve information about a user's GitHub plan.
        The GitHub App must be authenticated as a user. See
        "[Identifying and authorizing users for GitHub Apps](https://docs.github.com/apps/building-github-apps/identifying-and-authorizing-users-for-github-apps/)"
        for details about authentication. For an example response, see 'Response with GitHub plan information' below"
        The `email` key in the following response is the publicly visible email address from your GitHub
        [profile page](https://github.com/settings/profile). When setting up your profile, you can select a primary email
        address to be ΓÇ£publicΓÇ¥ which provides an email entry for this endpoint. If you do not set a public email address for `email`,
        then it will have a value of `null`. You only see publicly visible email addresses when authenticated with GitHub.
        For more information, see [Authentication](https://docs.github.com/rest/overview/resources-in-the-rest-api#authentication).
        The Emails API enables you to list all of your email addresses, and toggle a primary email to be visible publicly.
        For more information, see "[Emails API](https://docs.github.com/rest/users/emails)".

        .EXAMPLE
        Get-GitHubUserByName -Name 'octocat'

        Get the 'octocat' user.

        .OUTPUTS
        GitHubUser

        .NOTES
        [Get a user](https://docs.github.com/rest/users/users#get-a-user)
    #>
    [OutputType([GitHubUser])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding()]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

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
            APIEndpoint = "/users/$Name"
            Context     = $Context
        }

        try {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                if ($_.Response.type -eq 'Organization') {
                    [GitHubOrganization]::New($_.Response, $Context.HostName)
                } elseif ($_.Response.type -eq 'User') {
                    [GitHubUser]::New($_.Response)
                } else {
                    [GitHubOwner]::New($_.Response)
                }
            }
        } catch {}
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
