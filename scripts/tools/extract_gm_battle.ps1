# 提取 game_manager.gd 战斗相关区段 (2361-2831)
$p = 'scripts/core/game_manager.gd'
$lines = Get-Content -Path $p -Encoding UTF8
$start = 2361 - 1
$end = [Math]::Min(2831, $lines.Count)
for ($i = $start; $i -lt $end; $i++) {
    Write-Output (($i + 1).ToString() + ": " + $lines[$i])
}
