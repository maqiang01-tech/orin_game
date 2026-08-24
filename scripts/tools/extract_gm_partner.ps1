# 提取 game_manager.gd 伙伴相关函数区域
$c = Get-Content 'scripts/core/game_manager.gd'

Write-Host '=== _build_partners_page 601-670 ==='
for ($i = 600; $i -le 669 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}

Write-Host ''
Write-Host '=== _build_partner_detail_popup 628-670 ==='
for ($i = 627; $i -le 669 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}

Write-Host ''
Write-Host '=== _refresh_partners 1294-1346 ==='
for ($i = 1293; $i -le 1345 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}

Write-Host ''
Write-Host '=== _on_partner_clicked 1316-1346 ==='
for ($i = 1315; $i -le 1345 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}
