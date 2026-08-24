# 提取伙伴数据样例（partners.json / survivors.json 前2个条目）与 game_manager 资源函数
Write-Host '=== partners.json 前60行 ==='
$p = Get-Content 'data/configs/partners.json' -TotalCount 60
$p

Write-Host ''
Write-Host '=== survivors.json 前60行 ==='
$s = Get-Content 'data/configs/survivors.json' -TotalCount 60
$s

Write-Host ''
Write-Host '=== game_manager.gd 成员变量(1-116) ==='
$c = Get-Content 'scripts/core/game_manager.gd'
for ($i = 0; $i -le 115 -and $i -lt $c.Count; $i++) {
    if ($c[$i] -match '^(var|const|@onready var)\s+\w+') {
        Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
    }
}

Write-Host ''
Write-Host '=== _format_resource_label 2072-2095 ==='
for ($i = 2071; $i -le 2094 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}

Write-Host ''
Write-Host '=== _on_heal_all_pressed / _on_rest_pressed 3301-3339 ==='
for ($i = 3300; $i -le 3338 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}
