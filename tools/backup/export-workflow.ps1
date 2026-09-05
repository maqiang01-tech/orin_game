param(
    [Parameter(Mandatory=$true)][string]$ProjectRoot,
    [Parameter(Mandatory=$true)][string]$Destination,
    [Parameter(Mandatory=$true)][string]$SkillsRoot,
    [Parameter(Mandatory=$true)][string]$DownloadsRoot
)
$ErrorActionPreference = 'Stop'
$project = (Resolve-Path -LiteralPath $ProjectRoot).Path
$destinationPath = [IO.Path]::GetFullPath($Destination)
if ($destinationPath -eq $project -or -not $destinationPath.StartsWith($project + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Destination must be a separate child checkout of ProjectRoot.'
}
$mappings = [Collections.Generic.List[object]]::new()
function Add-Mapping([string]$source, [string]$target, [bool]$topOnly=$false) {
    $mappings.Add([pscustomobject]@{source=$source;target=$target;topOnly=$topOnly})
}
foreach ($name in @('sabcd_workflow_stage1_starter','spabcd_workflow_v4_1_design_layer','benchmark')) {
    Add-Mapping (Join-Path $project $name) $name
}
Add-Mapping (Join-Path $project '.spabcd') 'project_snapshot/.spabcd'
Add-Mapping (Join-Path $project '.codex') 'project_snapshot/.codex'
Add-Mapping (Join-Path $project 'output') 'reports'
Add-Mapping (Join-Path $project 'docs/planning/archives') 'releases/p-skill'
foreach ($file in @('V1_2_1_SOURCE_RELEASE_2026-09-05.md','ROUND_CLOSEOUT_AUTONOMY_2026-09-05.md','SKILL_RESEARCH_GAMEPLAY_UI_ART_2026-09-05.md')) {
    Add-Mapping (Join-Path $project "docs/planning/$file") "docs/history/$file"
}
foreach ($version in @('101','102','103','104')) {
    $audit = "tmp/router_v${version}_independent_audit"
    Add-Mapping (Join-Path $project $audit) "audits/router_v$version" $true
    $packageVersion = '1_0_' + $version.Substring(2)
    $package = "spabcd_model_router_skill_v$packageVersion"
    Add-Mapping (Join-Path $project "$audit/$package") "audits/router_v$version/$package"
}
Add-Mapping (Join-Path $project 'tmp/router_v110_independent_audit') 'audits/router_v110'
Add-Mapping (Join-Path $project 'tmp/model_router_m7_shadow') 'audits/model_router_m7_shadow'
Add-Mapping (Join-Path $project 'tmp/skills_capability_audit_20260905') 'audits/skills_20260905' $true
foreach ($skill in @('asset-curator','codex-task-orchestrator','p-scheduler-bridge','task-continuity','yishi-art-production','yishi-design-iteration','yishi-godot-ui')) {
    Add-Mapping (Join-Path $SkillsRoot $skill) "skills/$skill"
}
foreach ($file in Get-ChildItem -LiteralPath $DownloadsRoot -File -Filter 'spabcd_model_router*.zip*') {
    Add-Mapping $file.FullName "releases/source-inputs/$($file.Name)"
}
Add-Mapping (Join-Path $DownloadsRoot 'spabcd_p_game_design_ui_experience_skill_v1_2.zip') 'releases/source-inputs/spabcd_p_game_design_ui_experience_skill_v1_2.zip'

$excluded = [Collections.Generic.List[object]]::new()
$entries = [Collections.Generic.List[object]]::new()
$skipDirs = @('.git','.godot','.vs','__pycache__','node_modules','.venv','context_hook_fixture')
function Get-SnapshotFiles([string]$root, [bool]$topOnly) {
    $item = Get-Item -LiteralPath $root -Force
    if (-not $item.PSIsContainer) { return $item }
    foreach ($child in Get-ChildItem -LiteralPath $root -Force) {
        if ($child.PSIsContainer -and ($skipDirs -contains $child.Name -or $topOnly)) { continue }
        if (($child.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Refusing reparse point: $($child.FullName)"
        }
        if ($child.PSIsContainer) {
            Get-SnapshotFiles $child.FullName $false
        } else { $child }
    }
}
foreach ($mapping in $mappings) {
    $rootItem = Get-Item -LiteralPath $mapping.source -Force
    foreach ($file in Get-SnapshotFiles $mapping.source $mapping.topOnly) {
        if ($file.Name -match '(?i)(\.(db|sqlite|sqlite3)(-(wal|shm|journal))?|\.py[co]|\.import|\.translation)$' -or $file.Name -match '(?i)^(auth|credentials)\.json$|^\.env($|\.)|\.(pem|key)$') {
            $excluded.Add([pscustomobject]@{source=$file.FullName;reason='database_cache_or_sensitive_filename'})
            continue
        }
        $relative = if ($rootItem.PSIsContainer) { [IO.Path]::GetRelativePath($rootItem.FullName,$file.FullName).Replace('\','/') } else { '' }
        $target = if ($relative) { "$($mapping.target)/$relative" } else { $mapping.target }
        $entries.Add([pscustomobject]@{path=$target;source=$file.FullName;sha256=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLower();bytes=$file.Length})
    }
}
if (($entries | Group-Object path | Where-Object Count -gt 1)) { throw 'Duplicate export destination.' }
$manifestPath = Join-Path $destinationPath 'BACKUP_MANIFEST.json'
if (Test-Path -LiteralPath $manifestPath) {
    $old = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $currentPaths = @($entries | ForEach-Object path)
    foreach ($entry in $old.files) {
        if ($entry.path -notin $currentPaths) { throw "Previously exported path disappeared; review manually: $($entry.path)" }
    }
}
foreach ($entry in $entries) {
    $target = Join-Path $destinationPath $entry.path
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target)) | Out-Null
    Copy-Item -LiteralPath $entry.source -Destination $target
    if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLower() -ne $entry.sha256) { throw "Copy hash mismatch: $($entry.path)" }
}
foreach ($entry in $entries) {
    if ((Get-FileHash -LiteralPath $entry.source -Algorithm SHA256).Hash.ToLower() -ne $entry.sha256) { throw "Source changed while exporting: $($entry.source)" }
}
$manifest = [ordered]@{
    schema='spabcd.git_backup_manifest.v1'
    generated_at_utc=[DateTime]::UtcNow.ToString('o')
    source_game_repository='git@github.com:maqiang01-tech/orin_game.git'
    scope='source_and_artifact_backup_not_activation'
    files=@($entries | Sort-Object path)
    excluded_files=@($excluded | Sort-Object source)
    excluded_directory_names=$skipDirs
}
[IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 8) + "`n", [Text.UTF8Encoding]::new($false))
[pscustomobject]@{files=$entries.Count;excluded=$excluded.Count;bytes=($entries | Measure-Object bytes -Sum).Sum;manifest=$manifestPath} | ConvertTo-Json
