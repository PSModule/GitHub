filter New-GitHubReleaseNote {
    <#
        .SYNOPSIS
        List releases

        .DESCRIPTION
        Generate a name and body describing a [release](https://docs.github.com/en/rest/releases/releases#get-a-release).
        The body content will be Markdown formatted and contain information like
        the changes since last release and users who contributed. The generated release notes are not saved anywhere. They are
        intended to be generated and used when creating a new release.

        .EXAMPLE
        $params = @{
            Owner                 = 'octocat'
            Repo                  = 'hello-world'
            TagName               = 'v1.0.0'
        }
        New-GitHubReleaseNote @params

        Creates a new release notes draft for the repository 'hello-world' owned by 'octocat' with the tag name 'v1.0.0'.
        In this example the tag 'v1.0.0' has to exist in the repository.
        The configuration file '.github/release.yml' or '.github/release.yaml' will be used.

        .EXAMPLE
        $params = @{
            Owner                 = 'octocat'
            Repo                  = 'hello-world'
            TagName               = 'v1.0.0'
            TargetCommitish       = 'main'
        }
        New-GitHubReleaseNote @params

        Creates a new release notes draft for the repository 'hello-world' owned by 'octocat' with the tag name 'v1.0.0'.
        In this example the tag 'v1.0.0' has to exist in the repository.

        .EXAMPLE
        $params = @{
            Owner                 = 'octocat'
            Repo                  = 'hello-world'
            TagName               = 'v1.0.0'
            TargetCommitish       = 'main'
            PreviousTagName       = 'v0.9.2'
            ConfigurationFilePath = '.github/custom_release_config.yml'
        }
        New-GitHubReleaseNote @params

        Creates a new release notes draft for the repository 'hello-world' owned by 'octocat' with the tag name 'v1.0.0'.
        The release notes will be based on the changes between the tags 'v0.9.2' and 'v1.0.0' and generated based on the
        configuration file located in the repository at '.github/custom_release_config.yml'.

        .NOTES
        [Generate release notes content for a release](https://docs.github.com/rest/releases/releases#list-releases)

    #>
    [OutputType([pscustomobject])]
    [Alias('Generate-GitHubReleaseNotes')]
    [Alias('New-GitHubReleaseNotes')]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubContextSetting -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubContextSetting -Name Repo),

        # The tag name for the release. This can be an existing tag or a new one.
        [Parameter(Mandatory)]
        [Alias('tag_name')]
        [string] $TagName,

        # Specifies the commitish value that will be the target for the release's tag.
        # Required if the supplied tag_name does not reference an existing tag.
        # Ignored if the tag_name already exists.
        [Parameter()]
        [Alias('target_commitish')]
        [string] $TargetCommitish,

        # The name of the previous tag to use as the starting point for the release notes.
        # Use to manually specify the range for the set of changes considered as part this release.
        [Parameter()]
        [Alias('previous_tag_name')]
        [string] $PreviousTagName,


        # Specifies a path to a file in the repository containing configuration settings used for generating the release notes.
        # If unspecified, the configuration file located in the repository at '.github/release.yml' or '.github/release.yaml' will be used.
        # If that is not present, the default configuration will be used.
        [Parameter()]
        [Alias('configuration_file_path')]
        [string] $ConfigurationFilePath

    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntry -Hashtable $body -RemoveNames 'Owner', 'Repo'

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/releases/generate-notes"
        Method      = 'POST'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("$Owner/$Repo", 'Create release notes')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

}
