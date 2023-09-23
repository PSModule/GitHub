Class Token {
    [string] $Value
    [datetime] $ExpirationDate

    Token() {
        $this.Value = ''
        $this.ExpirationDate = [datetime]::MinValue
    }
}

Class Auth {
    [Token] $AccessToken
    [string] $ClientID
    [string] $Mode
    [Token] $RefreshToken
    [string] $Scope

    Auth() {
        $this.AccessToken = [Token]::new()
        $this.ClientID = ''
        $this.Mode = ''
        $this.RefreshToken = [Token]::new()
        $this.Scope = ''
    }
}

Class UserDefaults {
    [string] $Owner
    [string] $Repo

    UserDefaults() {
        $this.Owner = ''
        $this.Repo = ''
    }
}
Class User {
    [Auth] $Auth
    [UserDefaults] $Defaults

    User() {
        $this.Auth = [Auth]::new()
        $this.Defaults = [UserDefaults]::new()
    }
}

Class API {
    [string] $BaseURI
    [string] $Version

    API() {
        $this.BaseURI = ''
        $this.Version = ''
    }
}

Class App {
    [API] $API

    App() {
        $this.API = [API]::new()
    }
}

Class Config {
    [App] $App
    [User] $User

    Config() {
        $this.App = [App]::new()
        $this.User = [User]::new()
    }
}
