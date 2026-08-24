# 列出 battle_system.gd 中所有函数签名
$c = Get-Content 'scripts/systems/battle_system.gd'
$lineNo = 0
foreach ($line in $c) {
    $lineNo++
    if ($line -match '^\s*(static\s+)?func\s+(\w+)') {
        Write-Host ("{0,4}: {1}" -f $lineNo, $line.Trim())
    }
}
