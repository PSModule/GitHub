function Get-GitHubSecretOwnerList {
    <#
        .SYNOPSIS
        List organization secrets.

        .DESCRIPTION
        Lists all secrets available in an organization without revealing their encrypted values. Authenticated users must have collaborator access to
        a repository to create, update, or read secrets. OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this
        endpoint. If the repository is private, the `repo` scope is also required.

        .EXAMPLE
        ```powershell
        Get-GitHubSecretOwnerList -Owner 'PSModule' -Context (Get-GitHubContext)
        ```

        Output:
        ```powershell
        ```

        Retrieves all secrets from the specified organization.

        .OUTPUTS
        GitHubSecret

        .NOTES
        An array of GitHubSecret objects representing the organization secrets.

        .NOTES
        [List organization secrets](https://docs.github.com/rest/actions/secrets#list-organization-secrets)
    #>
    [OutputType([GitHubSecret[]])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

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
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Owner/actions/secrets"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            $_.Response.secrets | ForEach-Object {
                $selectedRepositories = @()
                if ($_.visibility -eq 'selected') {
                    $selectedRepositories = Get-GitHubSecretSelectedRepository -Owner $Owner -Name $_.name -Context $Context
                }
                [GitHubSecret]::new($_, $Owner, $null, $null, $selectedRepositories)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
