$raw = [System.IO.StreamReader]::new([Console]::OpenStandardInput(), [System.Text.Encoding]::UTF8).ReadToEnd()
try {
    $d = $raw | ConvertFrom-Json
    $f = $d.tool_input.file_path
    if ($f -match '\.md$') {
        $name = Split-Path $f -Leaf
        $dir = Split-Path $f -Parent
        Set-Location $dir
        git add $f
        git commit -m "Add $name"
        git push origin main
    }
} catch {}
