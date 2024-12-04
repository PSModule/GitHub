filter Get-GitHubGitignoreByName {
    <#
        .SYNOPSIS
        Get a gitignore template

        .DESCRIPTION
        The API also allows fetching the source of a single template.
        Use the raw [media type](https://docs.github.com/rest/overview/media-types/) to get the raw contents.

        .EXAMPLE
        Get-GitHubGitignoreList

        Get all gitignore templates

        .NOTES
        https://docs.github.com/rest/gitignore/gitignore#get-a-gitignore-template

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        # The context to run the command in.
        [Parameter()]
        [string] $Context
    )

    process {
        $inputObject = @{
            Context     = $Context
            APIEndpoint = "/gitignore/templates/$Name"
            Accept      = 'application/vnd.github.raw+json'
            Method      = 'GET'
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }

    }
}
