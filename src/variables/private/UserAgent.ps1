$script:Prerelease = $script:PSModuleInfo.PrivateData.PSData.Prerelease
$script:UserAgent = "PSModule.GitHub $($script:PSModuleInfo.ModuleVersion)"
if ($script:Prerelease) {
    $script:UserAgent += "-$script:Prerelease"
}
