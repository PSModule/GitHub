filter Add-GitHubUserSigningKey {
    <#
        .SYNOPSIS
        Create a SSH signing key for the authenticated user

        .DESCRIPTION
        Creates an SSH signing key for the authenticated user's GitHub account.
        You must authenticate with Basic Authentication, or you must authenticate with OAuth with at least `write:ssh_signing_key` scope.
        For more information, see
        "[Understanding scopes for OAuth apps](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/)."

        .EXAMPLE
        Add-GitHubUserSigningKey -Title 'ssh-rsa AAAAB3NzaC1yc2EAAA' -Key '2Sg8iYjAxxmI2LvUXpJjkYrMxURPc8r+dB7TJyvv1234'

        Creates a new SSH signing key for the authenticated user's GitHub account.

        .NOTES
        [Create a SSH signing key for the authenticated user](https://docs.github.com/rest/users/ssh-signing-keys#create-a-ssh-signing-key-for-the-authenticated-user)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long links for documentation.')]
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # A descriptive name for the new key.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('name')]
        [string] $Title,

        # The public SSH key to add to your GitHub account. For more information, see
        # [Checking for existing SSH keys](https://docs.github.com/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys)."
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Key,

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
        try {
            $body = @{
                title = $Title
                key   = $Key
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/user/ssh_signing_keys'
                Method      = 'Post'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
