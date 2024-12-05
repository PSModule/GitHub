filter Set-GitHubUser {
    <#
        .SYNOPSIS
        Update the authenticated user

        .DESCRIPTION
        **Note:** If your email is set to private and you send an `email` parameter as part of this request
        to update your profile, your privacy settings are still enforced: the email address will not be
        displayed on your public profile or via the API.

        .EXAMPLE
        Set-GitHubUser -Name 'octocat'

        Update the authenticated user's name to 'octocat'

        .EXAMPLE
        Set-GitHubUser -Location 'San Francisco'

        Update the authenticated user's location to 'San Francisco'

        .EXAMPLE
        Set-GitHubUser -Hireable $true -Bio 'I love programming'

        Update the authenticated user's hiring availability to 'true' and their biography to 'I love programming'

        .NOTES
        [Update the authenticated user](https://docs.github.com/rest/users/users#update-the-authenticated-user)
    #>
    [OutputType([void])]
    [Alias('Update-GitHubUser')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The new name of the user.
        [Parameter()]
        [string] $Name,

        # The publicly visible email address of the user.
        [Parameter()]
        [string] $Email,

        # The new blog URL of the user.
        [Parameter()]
        [string] $Blog,

        # The new Twitter username of the user.
        [Parameter()]
        [string] $TwitterUsername,

        # The new company of the user.
        [Parameter()]
        [string] $Company,

        # The new location of the user.
        [Parameter()]
        [string] $Location,

        # The new hiring availability of the user.
        [Parameter()]
        [boolean] $Hireable,

        # The new short biography of the user.
        [Parameter()]
        [string] $Bio,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    $body = @{
        name             = $Name
        email            = $Email
        blog             = $Blog
        twitter_username = $TwitterUsername
        company          = $Company
        location         = $Location
        hireable         = $Hireable
        bio              = $Bio
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/user'
        Method      = 'PATCH'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess('authenticated user', 'Set')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
