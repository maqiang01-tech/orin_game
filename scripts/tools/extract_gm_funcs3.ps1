# 列出 game_manager.gd 所有函数定义
$c = Get-Content 'scripts/core/game_manager.gd'
Write-Host '=== game_manager.gd 函数列表 ==='
for ($i = 0; $i -lt $c.Count; $i++) {
    if ($c[$i] -match '^\s*func\s+\w+') {
        Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i].Trim())
    }
}
