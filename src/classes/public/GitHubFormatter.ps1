class GitHubFormatter {
    static [string] FormatColorByRatio([double]$Ratio, [string]$Text, $HostObject, $PSStyleObject) {
        if ($HostObject.UI.SupportsVirtualTerminal -and ($env:GITHUB_ACTIONS -ne 'true')) {
            # Ensure ratio is between 0 and 1
            $Ratio = [Math]::Min([Math]::Max($Ratio, 0), 1)

            if ($Ratio -ge 1) {
                $r = 0
                $g = 255
            } elseif ($Ratio -le 0) {
                $r = 255
                $g = 0
            } elseif ($Ratio -ge 0.5) {
                $r = [Math]::Round(255 * (2 - 2 * $Ratio))
                $g = 255
            } else {
                $r = 255
                $g = [Math]::Round(255 * (2 * $Ratio))
            }

            $color = $PSStyleObject.Foreground.FromRgb($r, $g, 0)
            $reset = $PSStyleObject.Reset
            return "$color$Text$reset"
        }

        return $Text
    }
}
