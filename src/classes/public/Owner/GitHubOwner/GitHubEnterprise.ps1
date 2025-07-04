class GitHubEnterprise : GitHubOwner {
    # The description of the organization.
    # Example: A great organization
    [string] $Description

    [string] $DescriptionHTML

    # The billing information for the organization.
    [GitHubBillingInfo] $BillingInfo

    # The billing email address for the organization.
    # Example: org@example.com
    [string] $BillingEmail

    # The readme of the organization.
    [string] $Readme

    [string] $ReadmeHTML


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
        $this.Company = $Object.company
        $this.Blog = $Object.websiteUrl
        $this.Location = $Object.location
        $this.CreatedAt = $Object.createdAt
        $this.UpdatedAt = $Object.updatedAt

        # From GitHubEnterprise
        $this.Description = $Object.description
        $this.DescriptionHTML = $Object.descriptionHTML
        $this.BillingEmail = $Object.billingEmail
        $this.BillingInfo = [GitHubBillingInfo]::new($Object.billingInfo)
        $this.Readme = $Object.readme
        $this.ReadmeHTML = $Object.readmeHTML
    }

    [string] ToString() {
        return $this.Name
    }
}
