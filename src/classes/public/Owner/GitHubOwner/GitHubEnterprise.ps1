class GitHubEnterprise : GitHubOwner {
    # The billing email address for the organization.
    # Example: org@example.com
    [string] $BillingEmail

    # The readme of the enterprise.
    # Example: This is the readme for the enterprise
    [string] $Readme

    # The readme of the enterprise, as HTML.
    # Example: <p>This is the readme for the enterprise</p>
    [string] $ReadmeHTML

    static [hashtable] $PropertyToGraphQLMap = @{
        ID           = 'databaseId'
        NodeID       = 'id'
        Name         = 'slug'
        DisplayName  = 'name'
        AvatarUrl    = 'avatarUrl'
        Url          = 'url'
        Type         = $Object.type ?? 'Enterprise'
        Website      = 'websiteUrl'
        Location     = 'location'
        CreatedAt    = 'createdAt'
        UpdatedAt    = 'updatedAt'
        Description  = 'description'
        BillingEmail = 'billingEmail'
        Readme       = 'readme'
        ReadmeHTML   = 'readmeHTML'
    }

    GitHubEnterprise() {}

    GitHubEnterprise([PSCustomObject] $Object) {
        # From GitHubNode
        $this.ID = $Object.databaseId
        $this.NodeID = $Object.id

        # From GitHubOwner
        $this.Name = $Object.slug
        $this.DisplayName = $Object.name
        $this.AvatarUrl = $Object.avatarUrl
        $this.Url = $Object.url
        $this.Type = $Object.type ?? 'Enterprise'
        $this.Location = $Object.location
        $this.Description = $Object.description
        $this.Website = $Object.websiteUrl
        $this.CreatedAt = $Object.createdAt
        $this.UpdatedAt = $Object.updatedAt

        # From GitHubEnterprise
        $this.BillingEmail = $Object.billingEmail
        $this.Readme = $Object.readme
        $this.ReadmeHTML = $Object.readmeHTML
    }

    [string] ToString() {
        return $this.Name
    }
}
