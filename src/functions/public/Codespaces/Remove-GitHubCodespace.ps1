function Remove-GitHubCodespace {
    <#
    .SYNOPSIS
        Delete a codespace.

    .PARAMETER Organization
        The organization name. The name is not case sensitive.

    .PARAMETER User
        The handle for the GitHub user account.

    .PARAMETER Name
        The name of the codespace.

    .EXAMPLE
        > Remove-GitHubCodespace -Name urban-dollop-pqxgrq55v4c97g4
                                                                                                                        
        Request           : {[Authentication, Bearer], [Method, Delete], [Token, System.Security.SecureString], [Headers, System.Collections.Hashtable]…}
        Response          : 
        Headers           : @{Access-Control-Allow-Origin=*; Access-Control-Expose-Headers=ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource,  
                            X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset; Content-Length=2;
                            Content-Security-Policy=default-src 'none'; Content-Type=application/json; charset=utf-8; Date=Sun, 02 Feb 2025 00:51:10 GMT; github-authentication-token-expiration=2025-05-01 01:22:47 UTC;      
                            Referrer-Policy=origin-when-cross-origin, strict-origin-when-cross-origin; Server=github.com; Strict-Transport-Security=max-age=31536000; includeSubdomains; preload; Vary=Accept-Encoding,        
                            Accept, X-Requested-With; x-accepted-oauth-scopes=codespace; X-Content-Type-Options=nosniff; X-Frame-Options=deny; x-github-api-version-selected=2022-11-28; x-github-media-type=github.v3;        
                            format=json; x-github-request-id=D313:3B725F:28042C0:50B3464:679EC17E; x-oauth-scopes=admin:enterprise, admin:gpg_key, admin:org, admin:org_hook, admin:public_key, admin:repo_hook,
                            admin:ssh_signing_key, audit_log, codespace, copilot, delete:packages, gist, notifications, project, repo, user, workflow, write:discussion, write:packages; x-ratelimit-limit=5000;
                            x-ratelimit-remaining=4991; x-ratelimit-reset=1738460387; x-ratelimit-resource=codespaces; x-ratelimit-used=9; X-XSS-Protection=0}
        StatusCode        : 202
        StatusDescription : Accepted

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#about-github-codespaces

    .LINK
        https://docs.github.com/en/rest/codespaces/organizations?apiVersion=2022-11-28#list-codespaces-for-a-user-in-organization
    #>
    [CmdletBinding(DefaultParameterSetName = 'User', SupportsShouldProcess)]
    param (
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [string]$Organization,

        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [string]$User,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Name,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    process {
        if ($PSCmdLet.ShouldProcess(
                "Deleting GitHub codespace [$Name]",
                "Are you sure you want to delete $($Name)?",
                'Delete codespace'
            )) {
            $delParams = @{
                APIEndpoint = $PSCmdlet.ParameterSetName -eq 'Organization' ?
                    "orgs/$Organization/members/$User/codespaces/$Name" :
                    "user/codespaces/$Name"
                Context     = $Context
                Method      = 'DELETE'
            }
            Invoke-GitHubAPI @delParams
        }
    }
}
