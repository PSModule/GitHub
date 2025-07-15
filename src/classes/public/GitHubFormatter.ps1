class GitHubFormatter {
    static [string] FormatColorByRatio([double]$Ratio, [string]$Text) {
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
        $color = "`e[38;2;$r;$g;0m"
        $reset = "`e[0m"
        return "$color$Text$reset"
    }

    static [string] FormatFileSize([long]$size) {
        switch ($size) {
            { $_ -ge 1TB } { return '{0:N2} TB' -f ($size / 1TB) }
            { $_ -ge 1GB } { return '{0:N2} GB' -f ($size / 1GB) }
            { $_ -ge 1MB } { return '{0:N2} MB' -f ($size / 1MB) }
            { $_ -ge 1KB } { return '{0:N2} KB' -f ($size / 1KB) }
        }
        return "$size  B"
    }
}
