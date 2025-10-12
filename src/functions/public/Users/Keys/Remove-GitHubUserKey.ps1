filter Remove-GitHubUserKey {
    <#
        .SYNOPSIS
        Delete a public SSH key for the authenticated user

        .DESCRIPTION
        Removes a public SSH key from the authenticated user's GitHub account.
        Requires that you are authenticated via Basic Auth or via OAuth with at least `admin:public_key`
        [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        ```powershell
        Remove-GitHubUserKey -ID '1234567'
        ```

        Deletes the public SSH key with ID '1234567' from the authenticated user's GitHub account.

        .NOTES
        [Delete a public SSH key for the authenticated user](https://docs.github.com/rest/users/keys#delete-a-public-ssh-key-for-the-authenticated-user)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Keys/Remove-GitHubUserKey
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        # The unique identifier of the key.
        [Parameter(
            Mandatory
        )]
        [Alias('key_id')]
        [string] $ID,

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
        $apiParams = @{
            Method      = 'DELETE'
            APIEndpoint = "/user/keys/$ID"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Key with ID [$ID]", 'DELETE')) {
            Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
