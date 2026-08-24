# 提取 game_manager.gd 成员变量与初始化/数据加载函数
$c = Get-Content 'scripts/core/game_manager.gd'

Write-Host '=== 成员变量声明 (var/const/@onready) ==='
for ($i = 0; $i -lt $c.Count; $i++) {
    if ($c[$i] -match '^(var|const|@onready var)\s+\w+') {
        Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
    }
}

Write-Host ''
Write-Host '=== _ready 134-149 ==='
for ($i = 133; $i -le 148 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}

Write-Host ''
Write-Host '=== _build_status_bar 330-383 ==='
for ($i = 329; $i -le 382 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}

Write-Host ''
Write-Host '=== _refresh_status_bar 1048-1061 ==='
for ($i = 1047; $i -le 1060 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}
