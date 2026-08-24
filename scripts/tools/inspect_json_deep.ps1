param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [int]$MaxDepth = 4
)

function Get-JsonShape($obj, $depth) {
    $indent = "  " * $depth
    if ($null -eq $obj) {
        return $indent + "null"
    }
    if ($obj -is [System.Array]) {
        $lines = @($indent + "array[$($obj.Count)]")
        if ($obj.Count -gt 0 -and $depth -lt $MaxDepth) {
            $lines += Get-JsonShape $obj[0] ($depth + 1)
        }
        return $lines -join [Environment]::NewLine
    }
    if ($obj -is [PSCustomObject]) {
        $lines = @($indent + "{")
        foreach ($p in $obj.PSObject.Properties) {
            $lines += (Get-JsonShape $p.Value ($depth + 1))
        }
        $lines += $indent + "}"
        return $lines -join [Environment]::NewLine
    }
    # 标量或字符串
    return $indent + "$($obj.GetType().Name): $obj"
}

try {
    $json = Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    Write-Output ("PARSE_ERROR: " + $_.Exception.Message)
    exit 1
}

Write-Output ("===== " + (Split-Path $Path -Leaf) + " =====")
Write-Output (Get-JsonShape $json 0)
