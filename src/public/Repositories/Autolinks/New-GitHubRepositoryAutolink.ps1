filter New-GitHubRepositoryAutolink {
    <#
        .SYNOPSIS
        Create an autolink reference for a repository

        .DESCRIPTION
        Users with admin access to the repository can create an autolink.

        .EXAMPLE
        New-GitHubRepositoryAutolink -Owner 'octocat' -Repo 'Hello-World' -KeyPrefix 'GH-' -UrlTemplate 'https://www.example.com/issue/<num>'

        Creates an autolink for the repository 'Hello-World' owned by 'octocat' that links to <'https://www.example.com/issue/<num>'>
        when the prefix GH- is found in an issue, pull request, or commit.

        .NOTES
        [Create an autolink reference for a repository](https://docs.github.com/rest/repos/autolinks#create-an-autolink-reference-for-a-repository)

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
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
        [bool] $IsAlphanumeric = $true
    )

    $PSCmdlet.MyInvocation.MyCommand.Parameters.GetEnumerator() | ForEach-Object {
        $paramName = $_.Key
        $paramDefaultValue = Get-Variable -Name $paramName -ValueOnly -ErrorAction SilentlyContinue
        $providedValue = $PSBoundParameters[$paramName]
        Write-Verbose "[$paramName]"
        Write-Verbose "  - Default:  [$paramDefaultValue]"
        Write-Verbose "  - Provided: [$providedValue]"
        if (-not $PSBoundParameters.ContainsKey($paramName) -and ($null -ne $paramDefaultValue)) {
            Write-Verbose '  - Using default value'
            $PSBoundParameters[$paramName] = $paramDefaultValue
        } else {
            Write-Verbose '  - Using provided value'
        }
    }

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntry -Hashtable $body -RemoveNames 'Owner', 'Repo' -RemoveTypes 'SwitchParameter'

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/autolinks"
        Method      = 'POST'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("Autolink for repository [$Owner/$Repo]", 'Create')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
