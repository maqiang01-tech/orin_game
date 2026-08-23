param(
    [string]$Pattern = "region_data",
    [string]$Path = "scripts"
)
Get-ChildItem -Path $Path -Filter "*.gd" -Recurse | Select-String -Pattern $Pattern | ForEach-Object {
    "$($_.Path):$($_.LineNumber): $($_.Line.Trim())"
}
