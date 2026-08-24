# 提取 game_manager.gd _process_site_cell(2012-2040) 与战斗成员变量声明
$c = Get-Content 'scripts/core/game_manager.gd'
Write-Host '=== _process_site_cell 2012-2041 ==='
for ($i = 2011; $i -le 2040 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}
Write-Host ''
Write-Host '=== 战斗成员变量声明 ==='
for ($i = 0; $i -lt $c.Count; $i++) {
    if ($c[$i] -match '^(var|@onready var)\s+battle_') {
        Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
    }
}
