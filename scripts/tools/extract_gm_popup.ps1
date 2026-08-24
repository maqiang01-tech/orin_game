# 提取 game_manager.gd _build_battle_popup(670-843)
$c = Get-Content 'scripts/core/game_manager.gd'
Write-Host '=== _build_battle_popup 670-843 ==='
for ($i = 669; $i -le 842 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}
