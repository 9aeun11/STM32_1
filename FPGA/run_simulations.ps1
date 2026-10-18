$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$labs = @('Piano', 'Traffic', 'ADC')

foreach ($lab in $labs) {
    $name = $lab.ToLowerInvariant()
    $folder = Join-Path $root $lab
    Push-Location -LiteralPath $folder
    try {
        Write-Host "=== ${lab}: compile ==="
        & iverilog -g2012 -s "tb_$name" -o simulation.vvp "$name.sv" "tb_$name.sv" 2>&1 | Tee-Object -FilePath compile.log
        if ($LASTEXITCODE -ne 0) { throw "$lab compile failed" }
        Write-Host "=== ${lab}: simulate ==="
        & vvp simulation.vvp 2>&1 | Tee-Object -FilePath simulation.log
        if ($LASTEXITCODE -ne 0) { throw "$lab simulation failed" }
        if (-not (Test-Path -LiteralPath wave.vcd)) { throw "$lab did not create wave.vcd" }
    }
    finally {
        Pop-Location
    }
}
