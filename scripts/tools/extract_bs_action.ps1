# 提取 battle_system.gd perform_action 签名(423-473) 与 decide_ai_action 返回(871-958)
$c = Get-Content 'scripts/systems/battle_system.gd'

Write-Host '=== perform_action 423-473 ==='
for ($i = 422; $i -le 472 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}

Write-Host ''
Write-Host '=== decide_ai_action 871-958 (前40行) ==='
for ($i = 870; $i -le 909 -and $i -lt $c.Count; $i++) {
    Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
}
