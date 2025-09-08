function Get-GitHubPermissionDefinition {
    <#
        .SYNOPSIS
        Retrieves GitHub permission definitions

        .DESCRIPTION
        Gets the list of GitHub permission definitions from the module's internal data store.
        This includes fine-grained permissions for repositories, organizations, and user accounts.
        The function supports filtering by permission type and scope to help you find specific permissions.

        File path-specific permissions are excluded from this list as they are handled differently 
        by the GitHub API (they appear under the FilePaths property in installation data rather 
        than as named permissions).

        .EXAMPLE
        Get-GitHubPermissionDefinition

        Gets all permission definitions.

        .EXAMPLE
        Get-GitHubPermissionDefinition -Type Fine-grained

        Gets all fine-grained permission definitions.

        .EXAMPLE
        Get-GitHubPermissionDefinition -Scope Repository

        Gets all permission definitions that apply to repository scope.

        .EXAMPLE
        Get-GitHubPermissionDefinition -Type Fine-grained -Scope Organization

        Gets all fine-grained permission definitions that apply to organization scope.

        .EXAMPLE
        Get-GitHubPermissionDefinition | Where-Object Name -eq 'contents'

        Gets the specific permission definition for 'contents' permission.

        .NOTES
        This function provides access to a curated list of GitHub permission definitions maintained within the module.
        The data includes permission names, display names, descriptions, available options, and scopes.
        
        File path permissions are excluded from this list as they are handled differently by the GitHub API.
        These permissions are user-specified paths with read/write access that appear in the FilePaths 
        property of GitHub App installation data, not as standard named permissions.
    #>
    [OutputType([GitHubPermission[]])]
    [CmdletBinding()]
    param(
        # Filter by permission type
        [Parameter()]
        [ValidateSet('Fine-grained', 'Classic')]
        [string] $Type,

        # Filter by permission scope
        [Parameter()]
        [ValidateSet('Repository', 'Organization', 'User', 'Enterprise')]
        [string] $Scope
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {
            # Start with all permissions
            $permissions = $script:GitHub.Permissions

            # Apply Type filter if specified
            if ($PSBoundParameters.ContainsKey('Type')) {
                $permissions = $permissions | Where-Object { $_.Type -eq $Type }
            }

            # Apply Scope filter if specified
            if ($PSBoundParameters.ContainsKey('Scope')) {
                $permissions = $permissions | Where-Object { $_.Scope -eq $Scope }
            }

            # Return the filtered results
            return $permissions
        } catch {
            Write-Error "Failed to retrieve GitHub permission definitions: $($_.Exception.Message)"
            throw
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}