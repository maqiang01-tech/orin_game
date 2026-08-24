param(
    [string]$TargetFile = "d:/GameDev/YiShiChenHuan/scripts/core/game_manager.gd",
    [string]$OutFile = "d:/GameDev/YiShiChenHuan/_gm_probe.txt"
)

$out = @()
$lines = Get-Content -Path $TargetFile -Encoding UTF8
for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^\s*(func|var|const|signal)\s+\w+' -or
        $line -match 'reincarnation' -or
        $line -match '轮回' -or
        $line -match 'boss_intel' -or
        $line -match 'main_story' -or
        $line -match 'chapter') {
        $out += "$($i+1):$line"
    }
}
$out | Out-File -FilePath $OutFile -Encoding utf8
Write-Output "Total matching lines: $($out.Count)"
