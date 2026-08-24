# 提取 game_manager.gd _ready(134-148) 与 _try_move_site_player(1971-2012)
$c = Get-Content 'scripts/core/game_manager.gd'
Write-Host '=== _ready 134-149 ==='
for ($i = 133; $i -le 148 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}
Write-Host ''
Write-Host '=== _try_move_site_player 1971-2013 ==='
for ($i = 1970; $i -le 2012 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}
