$p = 'scripts/systems/battle_system.gd'
$lines = Get-Content $p
Write-Output ("BS_TOTAL_LINES: " + $lines.Count)
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^func |^var |^const |^class_name |^extends ') {
        Write-Output (($i + 1).ToString() + ': ' + $lines[$i].Trim())
    }
}
