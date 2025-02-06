function Invoke-GitHubAppCreationForm {
    <#
        .SYNOPSIS
        Submits a GitHub App manifest to GitHub and returns a temporary creation code.

        .DESCRIPTION
        This function builds the manifest JSON payload from provided parameters and sends a POST request
        to the GitHub App creation endpoint (personal, organization, or enterprise). It then extracts the
        temporary code from the redirect URL. If something goes wrong, it writes an error.

        The function supports different parameter sets for creating apps under personal, organization, or
        enterprise accounts.

        .EXAMPLE
        $code = Invoke-GitHubAppCreationForm -Name "MyApp" -Url "https://example.com" -WebhookURL "https://example.com/webhook"

        Creates a GitHub App with the given name, homepage URL, and webhook URL, then returns a temporary
        creation code.

        .EXAMPLE
        $code = Invoke-GitHubAppCreationForm -Name "MyOrgApp" -Url "https://myorg.com" -Organization "MyOrg"

        Registers a GitHub App under the "MyOrg" organization and returns a temporary creation code.

        .NOTES
        [Registering a GitHub App from a manifest](https://docs.github.com/en/apps/sharing-github-apps/registering-a-github-app-from-a-manifest)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'log links are long'
    )]
    [CmdletBinding(DefaultParameterSetName = 'Personal')]
    param(
        # The name of the GitHub App.
        [Parameter(Mandatory)]
        [string] $Name,

        # The homepage URL of the GitHub App.
        [Parameter(Mandatory)]
        [string] $HomepageUrl,

        # Enables webhook support for the GitHub App.
        [Parameter()]
        [switch] $WebhookEnabled,

        # The webhook URL where GitHub will send event payloads.
        [Parameter()]
        [string] $WebhookURL,

        # The redirect URL after app creation.
        [Parameter()]
        [string] $RedirectUrl,

        # List of callback URLs for OAuth flows.
        [Parameter()]
        [string[]] $CallbackUrls,

        # The setup URL for the GitHub App.
        [Parameter()]
        [string] $SetupUrl,

        # A description of the GitHub App.
        [Parameter()]
        [string] $Description,

        # Indicates whether the app is public.
        [Parameter()]
        [switch] $Public,

        # List of default webhook events the GitHub App will subscribe to.
        [Parameter()]
        [string[]] $Events,

        # Permissions requested by the GitHub App.
        [Parameter()]
        [hashtable] $Permissions,

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

        # Determines if setup should be prompted when the app is updated.
        [Parameter()]
        [switch] $SetupOnUpdate,

        # The enterprise under which the app is being created (Enterprise parameter set).
        [Parameter(ParameterSetName = 'Enterprise', Mandatory)]
        [string] $Enterprise,

        # The organization under which the app is being created (Organization parameter set).
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [string] $Organization,

        # Optional state parameter to pass during app creation.
        [Parameter()]
        [string] $State,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        Write-Verbose 'Building GitHub App manifest JSON payload...'
        # Build the manifest object
        $manifest = @{
            name                     = $Name
            url                      = $HomepageUrl
            hook_attributes          = @{
                url    = $WebhookURL
                active = $WebhookEnabled
            }
            redirect_url             = $RedirectUrl
            callback_urls            = $CallbackUrls
            setup_url                = $SetupUrl
            description              = $Description
            public                   = $Public
            default_events           = $Events
            default_permissions      = $Permissions
            request_oauth_on_install = $RequestOAuthOnInstall
            setup_on_update          = $SetupOnUpdate
            device_flow              = $DeviceFlow
            expire_user_tokens       = $ExpireUserTokens
        }
        $manifest | ConvertTo-Json -Depth 10 -Compress

        # Determine target URL based on Org value
        switch ($PSCmdlet.ParameterSetName) {
            'Enterprise' {
                $targetUrl = "https://$($Context.HostName)/enterprises/$Enterprise/settings/apps/new"
            }
            'Organization' {
                $targetUrl = "https://$($Context.HostName)/organizations/$Organization/settings/apps/new"
            }
            'Personal' {
                $targetUrl = "https://$($Context.HostName)/settings/apps/new"
            }
        }

        if ($State) {
            if ($targetUrl -notlike '*?*') {
                $targetUrl = "$targetUrl?state=$State"
            } else {
                $targetUrl = "$targetUrl&state=$State"
            }
        }
        Write-Verbose "Sending manifest to GitHub App creation URL: $targetUrl"

        # Prepare the request body and headers
        $body = @{ manifest = $manifest }

        try {
            $inputObject = @{
                Method             = 'POST'
                Uri                = $targetUrl
                Body               = $body
                MaximumRedirection = 0
                Authentication     = 'Bearer'
                Token              = $Context.Token
                ErrorAction        = 'Stop'
            }
            Write-Verbose ($inputObject | Format-List | Out-String)
            $response = Invoke-WebRequest @inputObject
        } catch {
            Write-Error "Error sending manifest: $_"
            return
        }

        Write-Verbose "Received response: $($response.StatusCode)"
        Write-Verbose ($response | Format-List | Out-String)
        if ($response.StatusCode -ne 302) {
            Write-Error "Unexpected response code: $($response.StatusCode)"
            return
        }

        # Extract the 'code' from the redirect Location header
        $location = $response.Headers['Location']
        Write-Verbose "Received redirect location: $location"
        if (-not $location) {
            Write-Error 'No redirect location found. The app may not have been created.'
            return
        }
        $code = $null
        if ($location -match 'code=([^&]+)') {
            $code = $matches[1]
        }
        if (-not $code) {
            Write-Error 'Failed to parse the app creation code from redirect URL.'
            return
        }
        Write-Verbose "Extracted temporary code: $code"
        return $code
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
