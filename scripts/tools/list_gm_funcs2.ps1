# 列出 game_manager.gd 中所有函数签名（供战斗系统检查）
$c = Get-Content 'scripts/core/game_manager.gd'
$lineNo = 0
foreach ($line in $c) {
    $lineNo++
    if ($line -match '^\s*(func|static\s+func)\s+(\w+)') {
        Write-Host ("{0,4}: {1}" -f $lineNo, $line.Trim())
    }
}
Write-Host ("文件总行数: " + $c.Count)
</content>
</｜｜DSML｜｜>
