filter Get-GitHubGitignoreList {
    <#
        .SYNOPSIS
        Get all gitignore templates

        .DESCRIPTION
        List all templates available to pass as an option when
        [creating a repository](https://docs.github.com/rest/repos/repos#create-a-repository-for-the-authenticated-user).

        .EXAMPLE
        Get-GitHubGitignoreList

        Get all gitignore templates

        .NOTES
        https://docs.github.com/rest/gitignore/gitignore#get-all-gitignore-templates

    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param(
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
            APIEndpoint = '/gitignore/templates'
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
