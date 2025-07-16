function Add-GitHubKeyVaultJWTSignature {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [String]
        $JWT,
        [Parameter()]
        [String]
        $KeyReference = ''
    )

    $JwsResultAsByteArr = [System.Text.Encoding]::UTF8.GetBytes($JWT)
    $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($JwsResultAsByteArr)
    $hash64 = [Convert]::ToBase64String($hash)

    $params = @{
        Method  = 'POST'
        URI     = "$KeyReference/sign?api-version=7.4"
        Payload = @{
            alg   = 'RS256'
            value = $hash64
        } | ConvertTo-Json -Depth 2
    }
    $signature = Invoke-AzRestMethod @params | Select-Object -ExpandProperty Content | ConvertFrom-Json


    '{0}.{1}' -f $JWT, $signature.value
}

$jwt = ''
$clientId = ''
$KeyReference = 'https://psmodule-test-vault.vault.azure.net/keys/psmodule-org-app/569ae34250e64adca6a2b2d159d454a5'
