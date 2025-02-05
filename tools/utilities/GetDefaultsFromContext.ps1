if ([string]::IsNullOrEmpty($Enterprise)) {
    $Enterprise = $Context.Enterprise
}
Write-Debug "Enterprise: [$Enterprise]"

if ([string]::IsNullOrEmpty($Organization)) {
    $Organization = $Context.Organization
}
Write-Debug "Organization: [$Organization]"

if ([string]::IsNullOrEmpty($Owner)) {
    $Owner = $Context.Owner
}
Write-Debug "Owner: [$Owner]"

if ([string]::IsNullOrEmpty($Repo)) {
    $Repo = $Context.Repo
}
Write-Debug "Repo: [$Repo]"

# What about "Name", "Login", "Username"
