# =====================================================================
# BidbrainAI local dev stack - one-command control script
# =====================================================================
# Usage:
#   .\dev.ps1            start the stack (builds images on first run)
#   .\dev.ps1 up         same as above
#   .\dev.ps1 logs       follow api + portal logs
#   .\dev.ps1 down       stop the stack (data kept)
#   .\dev.ps1 reset      stop and WIPE the database + volumes
#   .\dev.ps1 rebuild    rebuild the api image (after api code changes)
#   .\dev.ps1 status     show container status
# =====================================================================

param(
    [ValidateSet("up", "down", "reset", "rebuild", "logs", "status")]
    [string]$Command = "up"
)

$ErrorActionPreference = "Stop"
$composeDir = $PSScriptRoot

function Assert-Docker {
    try { docker info *> $null } catch {}
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Docker doesn't seem to be running. Start Docker Desktop and try again." -ForegroundColor Red
        exit 1
    }
}

Push-Location $composeDir
try {
    switch ($Command) {
        "up" {
            Assert-Docker
            Write-Host "Starting BidbrainAI dev stack (first run builds images and installs portal deps - can take several minutes)..." -ForegroundColor Cyan
            docker compose up -d --build
            if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
            Write-Host ""
            Write-Host "Stack is starting:" -ForegroundColor Green
            Write-Host "  Portal   http://localhost:3000   (first page load compiles - be patient)"
            Write-Host "  API      http://localhost:8000/docs"
            Write-Host "  Postgres localhost:5432  (postgres / postgres)"
            Write-Host ""
            Write-Host "Follow progress with:  .\dev.ps1 logs"
        }
        "down" {
            docker compose down
        }
        "reset" {
            Write-Host "This wipes the local database and portal caches." -ForegroundColor Yellow
            docker compose down -v
        }
        "rebuild" {
            Assert-Docker
            docker compose build migrations
            docker compose up -d --force-recreate migrations api
        }
        "logs" {
            docker compose logs -f api portal migrations
        }
        "status" {
            docker compose ps
        }
    }
}
finally {
    Pop-Location
}
