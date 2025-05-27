filter New-GitHubReleaseNote {
    <#
        .SYNOPSIS
        Generate release notes content for a release.

        .DESCRIPTION
        Generate a name and body describing a [release](https://docs.github.com/rest/releases/releases#generate-release-notes-content-for-a-release).
        The body content will be Markdown formatted and contain information like the changes since last release and users who contributed.
        The generated release notes are not saved anywhere. They are intended to be generated and used when creating a new release.

        .EXAMPLE
        $params = @{
            Owner = 'octocat'
            Repository = 'hello-world'
            Tag = 'v1.0.0'
        }
        New-GitHubReleaseNote @params

        Creates a new release notes draft for the repository 'hello-world' owned by 'octocat' with the tag name 'v1.0.0'.
        In this example the tag 'v1.0.0' has to exist in the repository.
        The configuration file '.github/release.yml' or '.github/release.yaml' will be used.

        .EXAMPLE
        $params = @{
            Owner = 'octocat'
            Repository = 'hello-world'
            Tag = 'v1.0.0'
            Target = 'main'
        }
        New-GitHubReleaseNote @params

        Creates a new release notes draft for the repository 'hello-world' owned by 'octocat' with the tag name 'v1.0.0'.
        In this example the tag 'v1.0.0' has to exist in the repository.

        .EXAMPLE
        $params = @{
            Owner = 'octocat'
            Repository = 'hello-world'
            Tag = 'v1.0.0'
            Target = 'main'
            PreviousTag = 'v0.9.2'
            ConfigurationFilePath = '.github/custom_release_config.yml'
        }
        New-GitHubReleaseNote @params

        Creates a new release notes draft for the repository 'hello-world' owned by 'octocat' with the tag name 'v1.0.0'.
        The release notes will be based on the changes between the tags 'v0.9.2' and 'v1.0.0' and generated based on the
        configuration file located in the repository at '.github/custom_release_config.yml'.

        .OUTPUTS
        pscustomobject

        .NOTES
        The returned object contains the following properties:
        - Name: The name of the release.
        - Notes: The body of the release notes.        .LINK
        https://psmodule.io/GitHub/Functions/Releases/New-GitHubReleaseNote/

        .NOTES
        [Generate release notes content for a release](https://docs.github.com/rest/releases/releases#generate-release-notes-content-for-a-release)
    #>
    [OutputType([pscustomobject])]
    [Alias('Generate-GitHubReleaseNotes')]
    [Alias('New-GitHubReleaseNotes')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The tag name for the release. This can be an existing tag or a new one.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Tag,

        # Specifies the commitish value that will be the target for the release's tag.
        # Required if the supplied tag_name does not reference an existing tag.
        # Ignored if the tag_name already exists.
        [Parameter()]
        [string] $Target,

        # The name of the previous tag to use as the starting point for the release notes.
        # Use to manually specify the range for the set of changes considered as part this release.
        [Parameter()]
        [string] $PreviousTag,

        # Specifies a path to a file in the repository containing configuration settings used for generating the release notes.
        # If unspecified, the configuration file located in the repository at '.github/release.yml' or '.github/release.yaml' will be used.
        # If that is not present, the default configuration will be used.
        [Parameter()]
        [string] $ConfigurationFilePath,

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
        $body = @{
            tag_name                = $Tag
            target_commitish        = $Target
            previous_tag_name       = $PreviousTag
            configuration_file_path = $ConfigurationFilePath
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = "/repos/$Owner/$Repository/releases/generate-notes"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("release notes for release on $Owner/$Repository", 'Create')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [PSCustomObject]@{
                    Name  = $_.Response.name
                    Notes = $_.Response.body
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
