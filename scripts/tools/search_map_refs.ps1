Get-ChildItem -Path "d:/GameDev/YiShiChenHuan" -Recurse -Include *.gd,*.tscn,*.godot | Select-String -Pattern 'world_map_wide_city_realm_v4|world_map_wide_city_realm_v5' | ForEach-Object {
    Write-Host ($_.Path + ":" + $_.LineNumber + ": " + $_.Line.Trim())
}
