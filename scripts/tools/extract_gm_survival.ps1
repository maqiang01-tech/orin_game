# 提取 game_manager.gd 中生存系统相关代码段
$c = Get-Content 'scripts/core/game_manager.gd'

Write-Host '=== _build_home_page (410-520) ==='
for ($i = 409; $i -le 519; $i++) { Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i]) }

Write-Host ''
Write-Host '=== _refresh_status_bar (1048-1060) ==='
for ($i = 1047; $i -le 1059; $i++) { Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i]) }

Write-Host ''
Write-Host '=== _refresh_home (1061-1132) ==='
for ($i = 1060; $i -le 1131; $i++) { Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i]) }

Write-Host ''
Write-Host '=== _on_heal_all_pressed / _on_rest_pressed (3302-3345) ==='
for ($i = 3301; $i -le 3344; $i++) { Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i]) }
