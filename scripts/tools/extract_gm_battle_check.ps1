# 提取 game_manager.gd 战斗相关段落（2361-2830行）
$c = Get-Content 'scripts/core/game_manager.gd'
Write-Host '=== 战斗段 2361-2830 ==='
for ($i = 2360; $i -le 2829 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}
