filter Add-GitHubUserSigningKey {
    <#
        .SYNOPSIS
        Create a SSH signing key for the authenticated user

        .DESCRIPTION
        Creates an SSH signing key for the authenticated user's GitHub account.
        You must authenticate with Basic Authentication, or you must authenticate with OAuth with at least `write:ssh_signing_key` scope. For more information, see "[Understanding scopes for OAuth apps](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/)."

        .EXAMPLE
        Add-GitHubUserSigningKey -Title 'ssh-rsa AAAAB3NzaC1yc2EAAA' -Key '2Sg8iYjAxxmI2LvUXpJjkYrMxURPc8r+dB7TJyvv1234'

        Creates a new SSH signing key for the authenticated user's GitHub account.

        .NOTES
        https://docs.github.com/rest/users/ssh-signing-keys#create-a-ssh-signing-key-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # A descriptive name for the new key.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('name')]
        [string] $Title,

        # The public SSH key to add to your GitHub account. For more information, see [Checking for existing SSH keys](https://docs.github.com/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys)."
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Key

    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case

    $inputObject = @{
        APIEndpoint = "/user/ssh_signing_keys"
        Method      = 'POST'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
