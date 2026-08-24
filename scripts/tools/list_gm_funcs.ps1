$p = 'scripts/core/game_manager.gd'
$lines = Get-Content $p
Write-Output ("GM_TOTAL_LINES: " + $lines.Count)
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^func |^var |^const |^signal |^@onready') {
        Write-Output (($i + 1).ToString() + ': ' + $lines[$i].Trim())
    }
}
