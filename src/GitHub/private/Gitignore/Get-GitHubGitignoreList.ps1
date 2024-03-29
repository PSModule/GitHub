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
    param ()

    $inputObject = @{
        APIEndpoint = '/gitignore/templates'
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
