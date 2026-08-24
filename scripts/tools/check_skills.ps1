$ErrorActionPreference = "Stop"

$skillsRaw = Get-Content "data/configs/skills.json" -Raw -Encoding UTF8
$skills = $skillsRaw | ConvertFrom-Json
Write-Host "=== SKILLS ==="
$skills.PSObject.Properties | ForEach-Object {
    $name = $_.Name
    $type = $_.Value.type
    $target = $_.Value.target
    $dmgType = $_.Value.damage_type
    Write-Host ("{0} | type={1} | target={2} | damage_type={3}" -f $name, $type, $target, $dmgType)
}

Write-Host ""
Write-Host "=== SURVIVORS SKILL REFERENCES ==="
$survRaw = Get-Content "data/configs/survivors.json" -Raw -Encoding UTF8
$surv = $survRaw | ConvertFrom-Json
$surv.PSObject.Properties | ForEach-Object {
    $sid = $_.Name
    $skillList = $_.Value.skills
    Write-Host ("{0} skills=" -f $sid)
    $skillList | ForEach-Object { Write-Host ("   - {0}" -f $_) }
}

Write-Host ""
Write-Host "=== PARTNERS SKILL REFERENCES ==="
$partRaw = Get-Content "data/configs/partners.json" -Raw -Encoding UTF8
$part = $partRaw | ConvertFrom-Json
$part.PSObject.Properties | ForEach-Object {
    $skey = $_.Name
    $skillList = $_.Value.skills
    Write-Host ("{0} skills=" -f $skey)
    $skillList | ForEach-Object { Write-Host ("   - {0}" -f $_) }
}
