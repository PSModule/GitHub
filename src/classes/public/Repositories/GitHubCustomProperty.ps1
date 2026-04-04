class GitHubCustomProperty {
    # The name of the custom property.
    [string] $Name

    # The value of the custom property.
    [string] $Value

    GitHubCustomProperty() {}

    GitHubCustomProperty([PSCustomObject] $Object) {
        $this.Name = $Object.property_name ?? $Object.propertyName ?? $Object.Name
        $this.Value = $Object.value ?? $Object.Value
    }

    [string] ToString() {
        return $this.Name
    }
}
