filter Add-GitHubUserKey {
    <#
        .SYNOPSIS
        Create a public SSH key for the authenticated user

        .DESCRIPTION
        Adds a public SSH key to the authenticated user's GitHub account.
        Requires that you are authenticated via Basic Auth, or OAuth with at least `write:public_key`
        [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        ```pwsh
        Add-GitHubUserKey -Title 'ssh-rsa AAAAB3NzaC1yc2EAAA' -Key '2Sg8iYjAxxmI2LvUXpJjkYrMxURPc8r+dB7TJyvv1234'
        ```

        Adds a new public SSH key to the authenticated user's GitHub account.

        .NOTES
        [Create a public SSH key for the authenticated user](https://docs.github.com/rest/users/keys#create-a-public-ssh-key-for-the-authenticated-user)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Keys/Add-GitHubUserKey
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long links for documentation.')]
    [CmdletBinding()]
    param(
        # A descriptive name for the new key.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('name')]
        [string] $Title,

        # The public SSH key to add to your GitHub account.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Key,

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
            title = $Title
            key   = $Key
        }

        $apiParams = @{
            Method      = 'POST'
            APIEndpoint = '/user/keys'
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
