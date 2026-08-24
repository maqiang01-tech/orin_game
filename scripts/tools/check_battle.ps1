$f = 'scripts/core/game_manager.gd'
$lines = Get-Content $f
Write-Output ("TOTAL_LINES: " + $lines.Count)
$patterns = '^func (_run_battle|_process_battle_turn|_auto_execute_ai|_auto_basic_decision|_apply_battle_action|_refresh_battle_ui|_update_battle_controls|_on_battle_attack_pressed|_on_battle_skill_pressed|_on_battle_guard_pressed|_on_battle_item_pressed|_on_battle_mode_pressed|_on_battle_close_pressed|_open_skill_popup|_on_skill_selected|_open_target_popup|_on_target_selected|_confirm_battle_action|_finish_battle|_sync_battle_results|_occupy_site_enemy_cell|_try_move_site_player)'
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match $patterns) {
        Write-Output (($i + 1).ToString() + ': ' + $lines[$i].Trim())
    }
}
$b = 'scripts/systems/battle_system.gd'
$blines = Get-Content $b
Write-Output ("BATTLE_TOTAL_LINES: " + $blines.Count)
