function Invoke-DrawMenu {
    ## supportfunction to the Menu function below
    param (
        $menuItems,
        $menuPosition,
        $menuTitel
    )
    $fcolor = $host.UI.RawUI.ForegroundColor
    $bcolor = $host.UI.RawUI.BackgroundColor
    $l = $menuItems.length + 1
    Clear-Host
    $menuwidth = $menuTitel.length + 4
    Write-Host "`t" -NoNewline
    Write-Host ('*' * $menuwidth) -fore $fcolor -back $bcolor
    Write-Host "`t" -NoNewline
    Write-Host "* $menuTitel *" -fore $fcolor -back $bcolor
    Write-Host "`t" -NoNewline
    Write-Host ('*' * $menuwidth) -fore $fcolor -back $bcolor
    Write-Host ''
    Write-Debug "L: $l MenuItems: $menuItems MenuPosition: $menuposition"
    for ($i = 0; $i -le $l; $i++) {
        Write-Host "`t" -NoNewline
        if ($i -eq $menuPosition) {
            Write-Host "$($menuItems[$i])" -fore $bcolor -back $fcolor
        } else {
            Write-Host "$($menuItems[$i])" -fore $fcolor -back $bcolor
        }
    }
}
