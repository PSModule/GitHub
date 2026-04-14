class GitHubCustomProperty {
    # The name of the custom property.
    [string] $Name

    # The value of the custom property. Can be a string or an array of strings for multi-select properties.
    [object] $Value

    GitHubCustomProperty() {}

    GitHubCustomProperty([PSCustomObject] $Object) {
        $this.Name = $Object.property_name ?? $Object.propertyName ?? $Object.Name
        $rawValue = $Object.value ?? $Object.Value
        if ($rawValue -is [System.Collections.IEnumerable] -and $rawValue -isnot [string]) {
            $this.Value = [string[]]$rawValue
        } else {
            $this.Value = $rawValue
        }
    }

    [string] ToString() {
        return $this.Name
    }
}
