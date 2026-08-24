# 提取 battle_system.gd 关键API定义与常量
$c = Get-Content 'scripts/systems/battle_system.gd'

Write-Host '=== 常量 STATUS_NAMES / MAX_PARTY_SIZE ==='
for ($i = 0; $i -lt $c.Count -and $i -lt 80; $i++) {
    if ($c[$i] -match 'STATUS_NAMES|MAX_PARTY_SIZE|const') {
        Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
    }
}

Write-Host ''
Write-Host '=== 函数签名 (func static) ==='
for ($i = 0; $i -lt $c.Count; $i++) {
    if ($c[$i] -match '^\s*(static\s+)?func\s+\w+') {
        Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
    }
}
