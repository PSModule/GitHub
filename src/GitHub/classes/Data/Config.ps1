$script:ConfigTemplate = [pscustomobject]@{
    App  = [pscustomobject]@{
        API      = [pscustomobject]@{
            BaseURI = 'https://api.github.com' # $script:ConfigTemplate.App.API.BaseURI
            Version = '2022-11-28'             # $script:ConfigTemplate.App.API.Version
        }
        Defaults = [pscustomobject]@{}         # $script:ConfigTemplate.App.Defaults
    }
}
$script:Config = $script:ConfigTemplate
