param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)
try {
    $json = Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    Write-Output ("PARSE_ERROR: " + $_.Exception.Message)
    exit 1
}

Write-Output ("ROOT_TYPE: " + $json.GetType().Name)

if ($json -is [System.Array]) {
    Write-Output ("ARRAY_SIZE: " + $json.Count)
    if ($json.Count -gt 0) {
        $first = $json[0]
        Write-Output ("FIRST_TYPE: " + $first.GetType().Name)
        if ($first -is [PSCustomObject]) {
            $props = $first.PSObject.Properties
            $keys = @()
            foreach ($p in $props) {
                $v = $p.Value
                $typeName = "null"
                if ($null -ne $v) { $typeName = $v.GetType().Name }
                # 简化嵌套类型
                if ($typeName -eq 'PSCustomObject') { $typeName = 'object' }
                elseif ($typeName -eq 'Object[]') { $typeName = 'array' }
                $keys += ($p.Name + ":" + $typeName)
            }
            Write-Output ("FIRST_KEYS: " + ($keys -join ", "))
        }
        # 打印前2条 id/name 便于识别
        for ($i = 0; $i -lt [Math]::Min(2, $json.Count); $i++) {
            $id = $json[$i].id
            $name = $json[$i].name
            Write-Output ("ENTRY_$i id=" + ($id -as [string]) + " name=" + ($name -as [string]))
        }
    }
} elseif ($json -is [PSCustomObject]) {
    $props = $json.PSObject.Properties
    $keys = @()
    foreach ($p in $props) {
        $v = $p.Value
        $typeName = "null"
        if ($null -ne $v) { $typeName = $v.GetType().Name }
        if ($typeName -eq 'PSCustomObject') { $typeName = 'object' }
        elseif ($typeName -eq 'Object[]') { 
            $typeName = 'array'
            if ($v.Count -gt 0) {
                $subType = $v[0].GetType().Name
                if ($subType -eq 'PSCustomObject') { 
                    $subKeys = @()
                    foreach ($sp in $v[0].PSObject.Properties) { $subKeys += $sp.Name }
                    $typeName += '<' + ($subKeys -join ',') + '>'
                } else { $typeName += '<' + $subType + '>' }
            }
        }
        $keys += ($p.Name + ":" + $typeName)
    }
    Write-Output ("ROOT_KEYS: " + ($keys -join ", "))
    Write-Output ("ROOT_SIZE: " + $json.PSObject.Properties.Count)
}
