# 提取 battle_system.gd 额外检查段
$c = Get-Content 'scripts/systems/battle_system.gd'

$sections = @(
    @{Name='=== _build_player_unit (123-189) ==='; Start=122; End=188},
    @{Name='=== _execute_skill (530-663) ==='; Start=529; End=662},
    @{Name='=== _process_round_end (769-846) ==='; Start=768; End=845}
)

foreach ($sec in $sections) {
    Write-Host $sec.Name
    for ($i = $sec.Start; $i -le $sec.End; $i++) {
        Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
    }
    Write-Host ''
}
