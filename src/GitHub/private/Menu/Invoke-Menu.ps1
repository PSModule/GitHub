function Invoke-Menu {
    ## Generate a small "DOS-like" menu.
    ## Choose a menuitem using up and down arrows, select by pressing ENTER
    param (
        [array]$menuItems,
        $menuTitel = 'MENU'
    )
    $vkeycode = 0
    $pos = 0
    Invoke-DrawMenu $menuItems $pos $menuTitel
    while ($vkeycode -ne 13) {
        $press = $host.ui.rawui.readkey('NoEcho,IncludeKeyDown')
        $vkeycode = $press.virtualkeycode
        Write-Host "$($press.character)" -NoNewline
        if ($vkeycode -eq 38) { $pos-- }
        if ($vkeycode -eq 40) { $pos++ }
        if ($pos -lt 0) { $pos = 0 }
        if ($pos -ge $menuItems.length) { $pos = $menuItems.length - 1 }
        Invoke-DrawMenu $menuItems $pos $menuTitel
    }
    $($menuItems[$pos])
}


<#
? What account do you want to log into?  [Use arrows to move, type to filter]
> GitHub.com
  GitHub Enterprise Server
#>
