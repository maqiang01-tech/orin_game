# 交叉验证 game_manager.gd 调用的 BattleSystem API 是否存在于 battle_system.gd
$bs = Get-Content 'scripts/systems/battle_system.gd'
$gm = Get-Content 'scripts/core/game_manager.gd'

# 收集 battle_system.gd 中的函数名 / 常量名 / 类名
$bsSymbols = @{}
foreach ($line in $bs) {
    if ($line -match '^\s*(static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)') {
        $bsSymbols[$matches[2]] = $true
    }
    if ($line -match '^const\s+([A-Za-z_][A-Za-z0-9_]*)') {
        $bsSymbols[$matches[1]] = $true
    }
    if ($line -match '^class_name\s+([A-Za-z_][A-Za-z0-9_]*)') {
        $bsSymbols[$matches[1]] = $true
    }
}
Write-Output ("BS_SYMBOLS: " + ($bsSymbols.Keys | Sort-Object) -join ', ')

# 收集 game_manager.gd 中的 BattleSystem.X 调用
$calls = @{}
$bsName = 'BattleSystem'
foreach ($line in $gm) {
    # 匹配 BattleSystem.xxx
    $pattern = [regex]::Escape($bsName) + '\.([A-Za-z_][A-Za-z0-9_]*)'
    foreach ($m in [regex]::Matches($line, $pattern)) {
        $sym = $m.Groups[1].Value
        if (-not $calls.ContainsKey($sym)) {
            $calls[$sym] = 0
        }
        $calls[$sym]++
    }
}
Write-Output ""
Write-Output "GM_BATTLESYSTEM_CALLS:"
foreach ($k in ($calls.Keys | Sort-Object)) {
    $status = 'OK'
    if (-not $bsSymbols.ContainsKey($k)) {
        $status = '<<< MISSING'
    }
    Write-Output ("  $k x$($calls[$k]) $status")
}
