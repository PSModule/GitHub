filter Update-GitHubUser {
    <#
        .SYNOPSIS
        Update the authenticated user

        .DESCRIPTION
        **Note:** If your email is set to private and you send an `email` parameter as part of this request
        to update your profile, your privacy settings are still enforced: the email address will not be
        displayed on your public profile or via the API.

        .EXAMPLE
        Update-GitHubUser -Name 'octocat'

        Update the authenticated user's name to 'octocat'

        .EXAMPLE
        Update-GitHubUser -Location 'San Francisco'

        Update the authenticated user's location to 'San Francisco'

        .EXAMPLE
        Update-GitHubUser -Hireable $true -Bio 'I love programming'

        Update the authenticated user's hiring availability to 'true' and their biography to 'I love programming'

        .NOTES
        [Update the authenticated user](https://docs.github.com/rest/users/users#update-the-authenticated-user)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Update-GitHubUser
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The display name of the user.
        [Parameter()]
        [string] $DisplayName,

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
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            name             = $DisplayName
            email            = $Email
            blog             = $Blog
            twitter_username = $TwitterUsername
            company          = $Company
            location         = $Location
            hireable         = $Hireable
            bio              = $Bio
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'PATCH'
            APIEndpoint = '/user'
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess('authenticated user', 'Set')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubUser]::New($_.Response)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
