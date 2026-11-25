Set-Location $PSScriptRoot
if (Test-Path '.env') {
  Get-Content '.env' | ForEach-Object {
    $line = $_.Trim()
    if ($line -and !$line.StartsWith('#') -and $line.Contains('=')) {
      $parts = $line.Split('=', 2)
      [Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim().Trim('"',"'"), 'Process')
    }
  }
}
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Host 'Instale Node.js 22.13+: https://nodejs.org/' -ForegroundColor Red
  Read-Host 'Enter para fechar'
  exit 1
}
if (!(Get-Command ffmpeg -ErrorAction SilentlyContinue)) { Write-Host 'ATENCAO: Instale FFmpeg para gerar cortes.' -ForegroundColor Yellow }
$port = if ($env:PORT) { $env:PORT } else { '3000' }
Start-Process "http://localhost:$port"
node server.js
Read-Host 'Enter para fechar'
