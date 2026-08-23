Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("d:/GameDev/YiShiChenHuan/assets/images/exploration/world_map_wide_city_realm_v5_clean.png")
Write-Host "Width: $($img.Width), Height: $($img.Height)"
$img.Dispose()
