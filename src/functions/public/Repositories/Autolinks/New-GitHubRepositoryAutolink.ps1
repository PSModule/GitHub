filter New-GitHubRepositoryAutolink {
    <#
        .SYNOPSIS
        Create an autolink reference for a repository

        .DESCRIPTION
        Users with admin access to the repository can create an autolink.

        .EXAMPLE
        New-GitHubRepositoryAutolink -Owner 'octocat' -Repo 'Hello-World' -KeyPrefix 'GH-' -UrlTemplate 'https://www.example.com/issue/<num>'

        Creates an autolink for the repository 'Hello-World' owned by 'octocat' that links to <https://www.example.com/issue/123>
        when the prefix 'GH-' is found in an issue, pull request, or commit.

        .NOTES
        [Create an autolink reference for a repository](https://docs.github.com/rest/repos/autolinks#create-an-autolink-reference-for-a-repository)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repo,

        # This prefix appended by certain characters will generate a link any time it is found in an issue, pull request, or commit.
        [Parameter(Mandatory)]
        [Alias('key_prefix')]
        [string] $KeyPrefix,

        # The URL must contain <num> for the reference number. <num> matches different characters depending on the value of is_alphanumeric.
        [Parameter(Mandatory)]
        [Alias('url_template')]
        [string] $UrlTemplate,

        # Whether this autolink reference matches alphanumeric characters. If true, the <num> parameter of the url_template matches alphanumeric
        # characters A-Z (case insensitive), 0-9, and -. If false, this autolink reference only matches numeric characters.
        [Parameter()]
        [Alias('is_alphanumeric')]
        [bool] $IsAlphanumeric = $true,

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

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo: [$Repo]"
    }

    process {
        try {
            $body = @{
                key_prefix      = $KeyPrefix
                url_template    = $UrlTemplate
                is_alphanumeric = $IsAlphanumeric
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/autolinks"
                Method      = 'Post'
                Body        = $body
            }

            if ($PSCmdlet.ShouldProcess("Autolink for repository [$Owner/$Repo]", 'Create')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
                }
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
