function New-GitHubApp {
    <#
        .SYNOPSIS
        Orchestrates the creation of a GitHub App.

        .DESCRIPTION
        This function ties together the manifest submission and conversion functions.
        It takes all the necessary app parameters, calls the function to send the manifest form,
        and then uses the temporary code to retrieve the final GitHub App configuration.

        .EXAMPLE
        $appDetails = New-GitHubApp -Name "MyApp" -Url "https://example.com" -WebhookURL "https://example.com/webhook" -Token "myToken"

        Creates a new GitHub App with the specified name, URL, webhook URL, and authentication token.

        .NOTES
        [GitHub Apps](https://docs.github.com/apps)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'log links are long'
    )]
    [CmdletBinding(DefaultParameterSetName = 'Personal', SupportsShouldProcess)]
    param(
        # The name of the GitHub App.
        [Parameter()]
        [string] $Name,

        # A brief description of the GitHub App.
        [Parameter()]
        [string] $Description,

        # The main URL of the GitHub App.
        [Parameter(Mandatory)]
        [string] $HomepageUrl,

        # List of callback URLs for OAuth authentication.
        [Parameter()]
        [string[]] $CallbackUrls,

        # This will provide a `refresh_token``  which can be used to request an updated access token when this access token expires.
        [Parameter()]
        [switch] $ExpireUserTokens,

        # Requests that the installing user grants access to their identity during installation of your App
        # Read our [Identifying and authorizing users for GitHub Apps documentation](https://docs.github.com/apps/building-github-apps/identifying-and-authorizing-users-for-github-apps/) for more information.
        [Parameter()]
        [switch] $RequestOAuthOnInstall,

        # Allow this GitHub App to authorize users via the Device Flow. Read the [Device Flow documentation](https://docs.github.com/apps/building-oauth-apps/authorizing-oauth-apps#device-flow) for more information.
        [Parameter()]
        [switch] $DeviceFlow,

        # The setup URL for the GitHub App.
        [Parameter()]
        [string] $SetupUrl,

        # Whether the setup process should run again when updating the app.
        [Parameter()]
        [switch] $SetupOnUpdate,

        # Enables or disables webhooks.
        [Parameter()]
        [switch] $WebhookEnabled,

        # The webhook URL for event notifications.
        [Parameter()]
        [string] $WebhookURL,

        # The redirect URL after authentication.
        [Parameter()]
        [string] $RedirectUrl,

        # The permissions required by the GitHub App.
        [Parameter()]
        [hashtable] $Permissions,

        # List of GitHub events the app subscribes to.
        [Parameter()]
        [string[]] $Events,

        # Specifies whether the app should be publicly visible.
        [Parameter()]
        [switch] $Public,

        # The enterprise under which the app is being created (Enterprise parameter set).
        [Parameter(ParameterSetName = 'Enterprise', Mandatory)]
        [string] $Enterprise,

        # The organization under which the app is being created (Organization parameter set).
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [string] $Organization,

        # The state parameter for additional configuration.
        [Parameter()]
        [string] $State,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }
    process {
        Write-Verbose 'Initiating GitHub App creation process...'
        # Step 1: Send manifest and get the temporary code
        $params = @{
            ExpireUserTokens      = $ExpireUserTokens
            DeviceFlow            = $DeviceFlow
            Name                  = $Name
            HomepageUrl           = $HomepageUrl
            WebhookEnabled        = $WebhookEnabled
            WebhookURL            = $WebhookURL
            RedirectUrl           = $RedirectUrl
            CallbackUrls          = $CallbackUrls
            SetupUrl              = $SetupUrl
            Description           = $Description
            Events                = $Events
            Permissions           = $Permissions
            RequestOAuthOnInstall = $RequestOAuthOnInstall
            SetupOnUpdate         = $SetupOnUpdate
            Public                = $Public
            State                 = $State
            Context               = $Context
        }

        switch ($PSCmdlet.ParameterSetName) {
            'Enterprise' {
                $params['Enterprise'] = $Enterprise
            }
            'Organization' {
                $params['Organization'] = $Organization
            }
        }

        $params | Format-Table | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
        $code = Invoke-GitHubAppCreationForm @params

        if (-not $code) {
            Write-Error 'Failed to retrieve temporary code from GitHub App manifest submission.'
            return
        }

        # Step 2: Convert the temporary code into final app details
        if ($PSCmdlet.ShouldProcess("$Name", 'Create GitHub App')) {
            $appDetails = Convert-GitHubAppManifest -Code $code -Context $Context
        }
        if (-not $appDetails) {
            Write-Error 'Failed to convert GitHub App manifest into final configuration.'
            return
        }

        Write-Verbose 'GitHub App created successfully.'
        return $appDetails
    }
    end {
        Write-Debug "[$stackPath] - End"
    }
}
