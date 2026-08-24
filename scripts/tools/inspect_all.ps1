# 批量检查 data/configs 下所有 JSON 配置文件的顶层结构
$configDir = "d:/GameDev/YiShiChenHuan/data/configs"
$files = Get-ChildItem -Path $configDir -Filter "*.json" | Sort-Object Name
foreach ($file in $files) {
    Write-Output ("===== " + $file.Name + " =====")
    & "d:/GameDev/YiShiChenHuan/scripts/tools/inspect_json.ps1" -Path $file.FullName
    Write-Output ""
}
