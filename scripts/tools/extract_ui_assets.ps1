param(
    [string]$SourceDir = "D:\image",
    [string]$OutDir = "assets\images\ui\extracted",
    [switch]$InfoOnly
)

Add-Type -AssemblyName System.Drawing

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Find-ImageByName([object[]]$Files, [string]$Pattern) {
    return $Files | Where-Object { $_.Name -like $Pattern } | Select-Object -First 1
}

function Save-Crop(
    [System.Drawing.Bitmap]$Source,
    [int]$X,
    [int]$Y,
    [int]$W,
    [int]$H,
    [string]$Path
) {
    $safeX = [Math]::Max(0, [Math]::Min($X, $Source.Width - 1))
    $safeY = [Math]::Max(0, [Math]::Min($Y, $Source.Height - 1))
    $safeW = [Math]::Max(1, [Math]::Min($W, $Source.Width - $safeX))
    $safeH = [Math]::Max(1, [Math]::Min($H, $Source.Height - $safeY))
    $rect = New-Object System.Drawing.Rectangle($safeX, $safeY, $safeW, $safeH)
    $crop = $Source.Clone($rect, $Source.PixelFormat)
    try {
        $crop.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $crop.Dispose()
    }
}

function Save-Crop-Padded(
    [System.Drawing.Bitmap]$Source,
    [int]$X,
    [int]$Y,
    [int]$W,
    [int]$H,
    [int]$OutW,
    [int]$OutH,
    [string]$Path
) {
    $safeX = [Math]::Max(0, [Math]::Min($X, $Source.Width - 1))
    $safeY = [Math]::Max(0, [Math]::Min($Y, $Source.Height - 1))
    $safeW = [Math]::Max(1, [Math]::Min($W, $Source.Width - $safeX))
    $safeH = [Math]::Max(1, [Math]::Min($H, $Source.Height - $safeY))
    $rect = New-Object System.Drawing.Rectangle($safeX, $safeY, $safeW, $safeH)
    $crop = $Source.Clone($rect, $Source.PixelFormat)
    $bmp = New-Object System.Drawing.Bitmap($OutW, $OutH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try {
        $g.Clear([System.Drawing.Color]::Transparent)
        $destX = [Math]::Floor(($OutW - $safeW) / 2)
        $destY = [Math]::Floor(($OutH - $safeH) / 2)
        $g.DrawImageUnscaled($crop, $destX, $destY)
        $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $g.Dispose()
        $bmp.Dispose()
        $crop.Dispose()
    }
}

function Save-Crop-Fit(
    [System.Drawing.Bitmap]$Source,
    [int]$X,
    [int]$Y,
    [int]$W,
    [int]$H,
    [int]$Inset,
    [string]$Path
) {
    $safeX = [Math]::Max(0, [Math]::Min($X, $Source.Width - 1))
    $safeY = [Math]::Max(0, [Math]::Min($Y, $Source.Height - 1))
    $safeW = [Math]::Max(1, [Math]::Min($W, $Source.Width - $safeX))
    $safeH = [Math]::Max(1, [Math]::Min($H, $Source.Height - $safeY))
    $rect = New-Object System.Drawing.Rectangle($safeX, $safeY, $safeW, $safeH)
    $crop = $Source.Clone($rect, $Source.PixelFormat)
    $bmp = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try {
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.Clear([System.Drawing.Color]::Transparent)
        $dest = New-Object System.Drawing.Rectangle($Inset, $Inset, ($W - $Inset * 2), ($H - $Inset * 2))
        $g.DrawImage($crop, $dest)
        $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $g.Dispose()
        $bmp.Dispose()
        $crop.Dispose()
    }
}

function New-StyleAsset(
    [int]$W,
    [int]$H,
    [string]$Path,
    [System.Drawing.Color]$Fill,
    [System.Drawing.Color]$Border,
    [int]$BorderWidth = 2,
    [int]$Radius = 8
) {
    $bmp = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try {
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.Clear([System.Drawing.Color]::Transparent)
        $rect = New-Object System.Drawing.Rectangle(1, 1, ($W - 3), ($H - 3))
        $diameter = [Math]::Max(2, $Radius * 2)
        $shapePath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $shapePath.AddArc($rect.X, $rect.Y, $diameter, $diameter, 180, 90)
        $shapePath.AddArc(($rect.Right - $diameter), $rect.Y, $diameter, $diameter, 270, 90)
        $shapePath.AddArc(($rect.Right - $diameter), ($rect.Bottom - $diameter), $diameter, $diameter, 0, 90)
        $shapePath.AddArc($rect.X, ($rect.Bottom - $diameter), $diameter, $diameter, 90, 90)
        $shapePath.CloseFigure()
        $brush = New-Object System.Drawing.SolidBrush($Fill)
        $pen = New-Object System.Drawing.Pen($Border, $BorderWidth)
        try {
            $g.FillPath($brush, $shapePath)
            $g.DrawPath($pen, $shapePath)
        } finally {
            $brush.Dispose()
            $pen.Dispose()
            $shapePath.Dispose()
        }
        $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $g.Dispose()
        $bmp.Dispose()
    }
}

$files = Get-ChildItem -LiteralPath $SourceDir -Filter *.png | Sort-Object LastWriteTime
foreach ($file in $files) {
    $img = [System.Drawing.Bitmap]::FromFile($file.FullName)
    try {
        Write-Output ("{0}`t{1}x{2}" -f $file.Name, $img.Width, $img.Height)
    } finally {
        $img.Dispose()
    }
}

if ($InfoOnly) {
    exit 0
}

Ensure-Dir $OutDir
Ensure-Dir (Join-Path $OutDir "buttons")
Ensure-Dir (Join-Path $OutDir "backgrounds")
Ensure-Dir (Join-Path $OutDir "panels")
Ensure-Dir (Join-Path $OutDir "status")
Ensure-Dir (Join-Path $OutDir "references")

$sourceImage = $files | Select-Object -Last 1

$assetSheet = Find-ImageByName $files "*00_22_56*"
if ($assetSheet -ne $null) {
    Copy-Item -LiteralPath $assetSheet.FullName -Destination (Join-Path $OutDir "references\ui_asset_sheet_latest.png") -Force
    $img = [System.Drawing.Bitmap]::FromFile($assetSheet.FullName)
    try {
        Save-Crop $img 1232 47 420 145 (Join-Path $OutDir "backgrounds\city_ruins.png")
        Save-Crop $img 1232 196 420 136 (Join-Path $OutDir "backgrounds\subway_station.png")
        Save-Crop $img 1232 347 420 136 (Join-Path $OutDir "backgrounds\shelter_camp.png")
        Save-Crop $img 1232 495 420 136 (Join-Path $OutDir "backgrounds\psychic_lab.png")
        Save-Crop $img 1232 644 420 108 (Join-Path $OutDir "backgrounds\mutation_nest.png")

        Save-Crop $img 569 459 113 50 (Join-Path $OutDir "buttons\nav_survival_normal.png")
        Save-Crop $img 693 459 113 50 (Join-Path $OutDir "buttons\nav_explore_normal.png")
        Save-Crop $img 817 459 113 50 (Join-Path $OutDir "buttons\nav_formation_normal.png")
        Save-Crop $img 939 459 113 50 (Join-Path $OutDir "buttons\nav_base_normal.png")
        Save-Crop $img 1063 459 132 50 (Join-Path $OutDir "buttons\nav_reincarnation_normal.png")
        Save-Crop $img 569 522 91 50 (Join-Path $OutDir "buttons\action_search.png")
        Save-Crop $img 670 522 91 50 (Join-Path $OutDir "buttons\action_rest.png")
        Save-Crop $img 773 522 91 50 (Join-Path $OutDir "buttons\action_leave.png")
        Save-Crop $img 984 522 209 50 (Join-Path $OutDir "buttons\primary_go.png")
        Save-Crop $img 569 589 91 50 (Join-Path $OutDir "buttons\battle_attack.png")
        Save-Crop $img 671 589 91 50 (Join-Path $OutDir "buttons\battle_auto.png")
        Save-Crop $img 775 589 91 50 (Join-Path $OutDir "buttons\battle_skill.png")
        Save-Crop $img 878 589 91 50 (Join-Path $OutDir "buttons\battle_item.png")
        Save-Crop $img 569 654 131 51 (Join-Path $OutDir "buttons\confirm.png")
        Save-Crop $img 710 654 133 51 (Join-Path $OutDir "buttons\cancel.png")
        Save-Crop $img 853 654 132 51 (Join-Path $OutDir "buttons\back.png")
        Save-Crop $img 995 654 132 51 (Join-Path $OutDir "buttons\close.png")

        Save-Crop $img 1077 802 118 139 (Join-Path $OutDir "panels\panel_red_title.png")
        Save-Crop $img 1205 802 118 139 (Join-Path $OutDir "panels\panel_dark_thin.png")
        Save-Crop $img 1332 802 118 139 (Join-Path $OutDir "panels\panel_amber_title.png")
        Save-Crop $img 1461 802 192 139 (Join-Path $OutDir "panels\panel_wide_dark.png")

        Save-Crop $img 568 797 475 53 (Join-Path $OutDir "status\resource_bar_full.png")
        Save-Crop $img 568 860 476 47 (Join-Path $OutDir "status\date_weather_bar.png")
    } finally {
        $img.Dispose()
    }
}

$buttonSheet = Find-ImageByName $files "*00_12_31 (1)*"
if ($buttonSheet -ne $null) {
    $img = [System.Drawing.Bitmap]::FromFile($buttonSheet.FullName)
    try {
        Copy-Item -LiteralPath $buttonSheet.FullName -Destination (Join-Path $OutDir "references\button_sheet_primary.png") -Force
        Save-Crop $img 24 81 488 152 (Join-Path $OutDir "buttons\primary_continue.png")
        Save-Crop $img 545 90 367 132 (Join-Path $OutDir "buttons\primary_go.png")
        Save-Crop $img 951 81 458 153 (Join-Path $OutDir "buttons\primary_reincarnation.png")
        Save-Crop $img 31 278 211 177 (Join-Path $OutDir "buttons\action_search.png")
        Save-Crop $img 264 278 214 177 (Join-Path $OutDir "buttons\action_rest.png")
        Save-Crop $img 496 278 211 177 (Join-Path $OutDir "buttons\action_leave.png")
        Save-Crop $img 730 278 222 177 (Join-Path $OutDir "buttons\action_adjust_team.png")
        Save-Crop $img 982 278 211 177 (Join-Path $OutDir "buttons\action_equipment.png")
        Save-Crop $img 1214 278 211 177 (Join-Path $OutDir "buttons\action_skill.png")
        Save-Crop $img 472 498 503 132 (Join-Path $OutDir "buttons\action_reward.png")
        $navW = 280
        $navH = 184
        Save-Crop-Padded $img 30 646 261 174 $navW $navH (Join-Path $OutDir "buttons\nav_survival_normal.png")
        Save-Crop-Padded $img 308 646 267 174 $navW $navH (Join-Path $OutDir "buttons\nav_explore_normal.png")
        Save-Crop-Padded $img 591 646 262 174 $navW $navH (Join-Path $OutDir "buttons\nav_formation_normal.png")
        Save-Crop-Padded $img 872 646 262 174 $navW $navH (Join-Path $OutDir "buttons\nav_base_normal.png")
        Save-Crop-Padded $img 1150 646 266 174 $navW $navH (Join-Path $OutDir "buttons\nav_reincarnation_normal.png")
        Save-Crop-Padded $img 27 822 266 183 $navW $navH (Join-Path $OutDir "buttons\nav_survival_selected.png")
        Save-Crop-Padded $img 308 822 268 183 $navW $navH (Join-Path $OutDir "buttons\nav_explore_selected.png")
        Save-Crop-Padded $img 589 822 265 184 $navW $navH (Join-Path $OutDir "buttons\nav_formation_selected.png")
        Save-Crop-Padded $img 872 822 262 183 $navW $navH (Join-Path $OutDir "buttons\nav_base_selected.png")
        Save-Crop-Padded $img 1152 822 262 183 $navW $navH (Join-Path $OutDir "buttons\nav_reincarnation_selected.png")
    } finally {
        $img.Dispose()
    }
}

$backgroundSheet = Find-ImageByName $files "*00_12_31 (3)*"
if ($backgroundSheet -ne $null) {
    $img = [System.Drawing.Bitmap]::FromFile($backgroundSheet.FullName)
    try {
        Save-Crop $img 31 110 657 332 (Join-Path $OutDir "backgrounds\subway_tunnel.png")
        Save-Crop $img 717 110 693 332 (Join-Path $OutDir "backgrounds\ruined_city_explore.png")
        Save-Crop $img 31 482 658 264 (Join-Path $OutDir "backgrounds\hospital_exterior.png")
        Save-Crop $img 716 482 694 265 (Join-Path $OutDir "backgrounds\reincarnation_hall.png")
        Save-Crop $img 29 789 1380 270 (Join-Path $OutDir "backgrounds\wide_ruined_city.png")
    } finally {
        $img.Dispose()
    }
}

$referenceSheet = Find-ImageByName $files "*22_54_48*"
if ($referenceSheet -ne $null) {
    Copy-Item -LiteralPath $referenceSheet.FullName -Destination (Join-Path $OutDir "references\ui_design_reference_latest.png") -Force
}

$img = [System.Drawing.Bitmap]::FromFile($sourceImage.FullName)
try {
    $w = $img.Width
    $h = $img.Height

    if ($w -eq 1024 -and $h -eq 1536) {
        Save-Crop $img 16 242 304 606 (Join-Path $OutDir "latest_phone_main_full.png")
        Save-Crop $img 338 280 218 352 (Join-Path $OutDir "latest_panel_survival.png")
        Save-Crop $img 575 280 212 352 (Join-Path $OutDir "latest_panel_explore.png")
        Save-Crop $img 792 280 218 352 (Join-Path $OutDir "latest_panel_formation.png")
        Save-Crop $img 338 664 253 339 (Join-Path $OutDir "latest_panel_base.png")
        Save-Crop $img 611 667 225 338 (Join-Path $OutDir "latest_panel_reincarnation.png")
        Save-Crop $img 16 1054 280 348 (Join-Path $OutDir "latest_panel_battle.png")
        Save-Crop $img 309 1054 222 348 (Join-Path $OutDir "latest_panel_boss_info.png")
        Save-Crop $img 548 1054 231 348 (Join-Path $OutDir "latest_panel_bag.png")
        Save-Crop $img 792 1054 218 348 (Join-Path $OutDir "latest_panel_death_result.png")

        Save-Crop $img 20 322 290 226 (Join-Path $OutDir "latest_bg_ruined_station.png")
        Save-Crop $img 684 39 136 146 (Join-Path $OutDir "latest_bg_city_small.png")
        Save-Crop $img 799 1055 203 72 (Join-Path $OutDir "latest_bg_result_header.png")

        Save-Crop $img 83 564 153 34 (Join-Path $OutDir "latest_button_primary_amber.png")
        Save-Crop $img 24 699 88 55 (Join-Path $OutDir "latest_button_action_dark_1.png")
        Save-Crop $img 118 699 88 55 (Join-Path $OutDir "latest_button_action_dark_2.png")
        Save-Crop $img 212 699 88 55 (Join-Path $OutDir "latest_button_action_dark_3.png")
        Save-Crop $img 24 699 88 55 (Join-Path $OutDir "button_main_search.png")
        Save-Crop $img 118 699 88 55 (Join-Path $OutDir "button_main_rest.png")
        Save-Crop $img 212 699 88 55 (Join-Path $OutDir "button_main_leave.png")
        Save-Crop $img 83 564 153 34 (Join-Path $OutDir "button_primary_continue.png")
        Save-Crop $img 557 968 187 33 (Join-Path $OutDir "latest_button_reincarnation_red.png")
        Save-Crop $img 351 967 207 33 (Join-Path $OutDir "latest_button_base_upgrade.png")

        Save-Crop $img 20 250 289 72 (Join-Path $OutDir "latest_top_status_bar.png")
        Save-Crop $img 20 607 289 86 (Join-Path $OutDir "latest_mission_panel.png")
        Save-Crop $img 20 767 289 78 (Join-Path $OutDir "latest_bottom_nav.png")
        Save-Crop $img 20 767 58 78 (Join-Path $OutDir "nav_survival_selected.png")
        Save-Crop $img 78 767 58 78 (Join-Path $OutDir "nav_explore_selected.png")
        Save-Crop $img 136 767 58 78 (Join-Path $OutDir "nav_formation_normal.png")
        Save-Crop $img 194 767 58 78 (Join-Path $OutDir "nav_base_normal.png")
        Save-Crop $img 252 767 57 78 (Join-Path $OutDir "nav_reincarnation_normal.png")
        Save-Crop $img 636 733 178 42 (Join-Path $OutDir "latest_progress_panel.png")
        Save-Crop $img 878 732 126 230 (Join-Path $OutDir "latest_right_menu.png")
        Save-Crop $img 490 1435 263 51 (Join-Path $OutDir "latest_button_style_samples.png")
        Save-Crop $img 836 1426 169 69 (Join-Path $OutDir "latest_icon_style_samples.png")
        Save-Crop $img 21 1098 268 148 (Join-Path $OutDir "battle_scene_monster_bg.png")
        Save-Crop $img 23 1307 48 34 (Join-Path $OutDir "battle_button_attack.png")
        Save-Crop $img 78 1307 48 34 (Join-Path $OutDir "battle_button_skill.png")
        Save-Crop $img 132 1307 48 34 (Join-Path $OutDir "battle_button_item.png")
        Save-Crop $img 187 1307 48 34 (Join-Path $OutDir "battle_button_guard.png")
        Save-Crop $img 241 1307 48 34 (Join-Path $OutDir "battle_button_retreat.png")
        Save-Crop $img 44 1353 48 27 (Join-Path $OutDir "battle_button_auto.png")
        Save-Crop $img 103 1353 48 27 (Join-Path $OutDir "battle_button_speed_1x.png")
        Save-Crop $img 162 1353 48 27 (Join-Path $OutDir "battle_button_speed_2x.png")
        Save-Crop $img 220 1353 48 27 (Join-Path $OutDir "battle_button_escape.png")
        Save-Crop $img 20 1399 289 51 (Join-Path $OutDir "ui_spec_color_band.png")
    } else {
        Save-Crop $img ([int]($w * 0.022)) ([int]($h * 0.140)) ([int]($w * 0.956)) ([int]($h * 0.350)) (Join-Path $OutDir "concept_hero_scene.png")
        Save-Crop $img ([int]($w * 0.022)) ([int]($h * 0.515)) ([int]($w * 0.224)) ([int]($h * 0.374)) (Join-Path $OutDir "concept_screen_survival.png")
        Save-Crop $img ([int]($w * 0.270)) ([int]($h * 0.515)) ([int]($w * 0.224)) ([int]($h * 0.374)) (Join-Path $OutDir "concept_screen_explore.png")
        Save-Crop $img ([int]($w * 0.515)) ([int]($h * 0.515)) ([int]($w * 0.224)) ([int]($h * 0.374)) (Join-Path $OutDir "concept_screen_formation.png")
        Save-Crop $img ([int]($w * 0.761)) ([int]($h * 0.515)) ([int]($w * 0.224)) ([int]($h * 0.374)) (Join-Path $OutDir "concept_screen_reincarnation.png")
        Save-Crop $img ([int]($w * 0.235)) ([int]($h * 0.895)) ([int]($w * 0.520)) ([int]($h * 0.075)) (Join-Path $OutDir "concept_feature_cards.png")
    }
} finally {
    $img.Dispose()
}

$screen = $files | Where-Object { $_.Name -like "*22_13_24 (2)*" } | Select-Object -First 1
$img = [System.Drawing.Bitmap]::FromFile($screen.FullName)
try {
    $w = $img.Width
    $h = $img.Height
    Save-Crop $img ([int]($w * 0.025)) ([int]($h * 0.520)) ([int]($w * 0.220)) ([int]($h * 0.365)) (Join-Path $OutDir "phone_frame_survival_full.png")
    Save-Crop $img ([int]($w * 0.025)) ([int]($h * 0.815)) ([int]($w * 0.220)) ([int]($h * 0.070)) (Join-Path $OutDir "phone_bottom_nav_sample.png")
    Save-Crop $img ([int]($w * 0.026)) ([int]($h * 0.645)) ([int]($w * 0.218)) ([int]($h * 0.085)) (Join-Path $OutDir "phone_mission_panel_sample.png")
    Save-Crop $img ([int]($w * 0.090)) ([int]($h * 0.470)) ([int]($w * 0.130)) ([int]($h * 0.060)) (Join-Path $OutDir "amber_primary_button_sample.png")
} finally {
    $img.Dispose()
}

Write-Output "Exported UI slices to $OutDir"

New-StyleAsset 256 64 (Join-Path $OutDir "component_button_dark_clean.png") ([System.Drawing.Color]::FromArgb(238, 18, 18, 16)) ([System.Drawing.Color]::FromArgb(205, 142, 96, 40)) 2 8
New-StyleAsset 256 64 (Join-Path $OutDir "component_button_amber_clean.png") ([System.Drawing.Color]::FromArgb(238, 86, 51, 12)) ([System.Drawing.Color]::FromArgb(235, 255, 170, 35)) 2 8
New-StyleAsset 256 64 (Join-Path $OutDir "component_button_red_clean.png") ([System.Drawing.Color]::FromArgb(238, 80, 18, 14)) ([System.Drawing.Color]::FromArgb(230, 220, 68, 48)) 2 8
New-StyleAsset 512 256 (Join-Path $OutDir "component_panel_dark_clean.png") ([System.Drawing.Color]::FromArgb(232, 16, 16, 14)) ([System.Drawing.Color]::FromArgb(180, 142, 112, 76)) 2 10
New-StyleAsset 192 300 (Join-Path $OutDir "component_unit_card_clean.png") ([System.Drawing.Color]::FromArgb(230, 14, 15, 14)) ([System.Drawing.Color]::FromArgb(215, 255, 180, 45)) 2 8
New-StyleAsset 192 18 (Join-Path $OutDir "component_bar_hp_red.png") ([System.Drawing.Color]::FromArgb(255, 220, 42, 36)) ([System.Drawing.Color]::FromArgb(200, 40, 18, 16)) 1 4
New-StyleAsset 192 18 (Join-Path $OutDir "component_bar_ep_blue.png") ([System.Drawing.Color]::FromArgb(255, 80, 172, 210)) ([System.Drawing.Color]::FromArgb(200, 20, 44, 58)) 1 4
