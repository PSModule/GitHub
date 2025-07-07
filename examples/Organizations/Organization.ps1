$orgParam = @{
    Enterprise   = 'msx'
    Name         = 'Marius-Test7'
    Owner        = 'GitHub-Automation'
    BillingEmail = 'post@msx.no'
}
$org = New-GitHubOrganization @orgParam

$installAppParam = @{
    Enterprise          = 'msx'
    Organization        = $org.login
    ClientID            = (Get-GitHubContext).ClientID
    RepositorySelection = 'all'
}
Install-GitHubApp @installAppParam

$updateOrgParam = @{
    Name                                                  = $org.login
    Description                                           = 'Test organization created by PowerShell script'
    Location                                              = 'Oslo, Norway'
    BillingEmail                                          = 'post@msx.no'
    Company                                               = 'MSX AS'
    Email                                                 = 'info@msx.no'
    Blog                                                  = 'https://msx.no/blog'
    TwitterUsername                                       = 'msx_no'
    HasOrganizationProjects                               = $true
    DefaultRepositoryPermission                           = 'read'
    MembersCanCreateRepositories                          = $true
    MembersCanCreatePublicRepositories                    = $true
    MembersCanCreatePrivateRepositories                   = $true
    MembersCanCreateInternalRepositories                  = $true
    MembersCanCreatePages                                 = $true
    MembersCanCreatePublicPages                           = $true
    MembersCanCreatePrivatePages                          = $true
    MembersCanForkPrivateRepositories                     = $true
    WebCommitSignoffRequired                              = $false
    SecretScanningPushProtectionEnabledForNewRepositories = $true
    SecretScanningPushProtectionCustomLinkEnabled         = $false
    SecretScanningPushProtectionCustomLink                = '<link>'
}
Update-GitHubOrganization @updateOrgParam
