# 提取 battle_system.gd 关键函数段落用于 API 核对
$c = Get-Content 'scripts/systems/battle_system.gd'

# 行号：1-based
$sections = @(
    @{Name='=== create_battle (68-115) ==='; Start=67; End=114},
    @{Name='=== get_alive_team_units (362-371) ==='; Start=361; End=370},
    @{Name='=== perform_action (423-474) ==='; Start=422; End=473},
    @{Name='=== advance_turn (739-769) ==='; Start=738; End=768},
    @{Name='=== check_battle_over (846-871) ==='; Start=845; End=870},
    @{Name='=== decide_ai_action (871-958) ==='; Start=870; End=957}
)

foreach ($sec in $sections) {
    Write-Host $sec.Name
    for ($i = $sec.Start; $i -le $sec.End; $i++) {
        Write-Host ("{0,4}: {1}" -f ($i + 1), $c[$i])
    }
    Write-Host ''
}
