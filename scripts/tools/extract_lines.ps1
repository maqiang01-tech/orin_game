param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [int]$Start,
    [Parameter(Mandatory = $true)]
    [int]$End
)
$lines = Get-Content $Path
if ($Start -lt 1) { $Start = 1 }
if ($End -gt $lines.Count) { $End = $lines.Count }
for ($i = $Start - 1; $i -lt $End; $i++) {
    Write-Output (($i + 1).ToString() + ': ' + $lines[$i])
}
