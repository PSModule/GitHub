function Set-GitHubUser {
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
        https://docs.github.com/rest/users/users#update-the-authenticated-user
    #>
    [OutputType([void])]
    [Alias('Update-GitHubUser')]
    [CmdletBinding()]
    param (
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
        [string] $Bio
    )

    $body = @{}

    $PSBoundParameters.GetEnumerator() | ForEach-Object {
        $body.($_.Key) = $_.Value
    }

    $inputObject = @{
        APIEndpoint = '/user'
        Body        = $body
        Method      = 'PATCH'
    }

    $inputObject

    $response = Invoke-GitHubAPI @inputObject

    $response
}
