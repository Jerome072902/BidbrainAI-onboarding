# =====================================================================
# dev-login.ps1 - mint a real local session for the portal
# =====================================================================
# What it does (local stack only):
#   1. Links a fixed fake supabase_user_id to a seeded demo user in the
#      local database (demo users ship with supabase_user_id = NULL).
#   2. Mints a JWT signed with the LOCAL SUPABASE_JWT_SECRET (the api
#      trusts it because it uses the same secret).
#   3. Prints a snippet you paste into the browser console to set the
#      bb_session cookie.
#
# Usage:
#   .\dev-login.ps1                          # sign in as lex@bidbrain.ai (bidbrain admin)
#   .\dev-login.ps1 -Email demo-admin.agency@bidbrain.ai
#   .\dev-login.ps1 -Days 7                  # shorter-lived token
# =====================================================================

param(
    [string]$Email = "lex@bidbrain.ai",
    [int]$Days = 30
)

$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot
try {
    # Deterministic fake gotrue id - stable across reruns.
    $subId = "11111111-1111-1111-1111-111111111111"

    Write-Host "Linking supabase_user_id to $Email in local db..." -ForegroundColor Cyan
    $sql = "UPDATE users SET supabase_user_id = NULL WHERE supabase_user_id = '$subId' AND email <> '$Email'; " +
           "UPDATE users SET supabase_user_id = '$subId' WHERE email = '$Email' RETURNING email;"
    $result = docker compose exec -T db psql -U postgres -d postgres -t -c $sql
    if ($LASTEXITCODE -ne 0) { Write-Host "psql failed - is the stack running? (.\dev.ps1)" -ForegroundColor Red; exit 1 }
    if (-not ($result | Select-String $Email)) {
        Write-Host "No user with email '$Email' found in local db." -ForegroundColor Red
        Write-Host "Available demo users:" -ForegroundColor Yellow
        docker compose exec -T db psql -U postgres -d postgres -c "SELECT email FROM users ORDER BY email;"
        exit 1
    }

    Write-Host "Minting local session JWT (valid $Days days)..." -ForegroundColor Cyan
    $py = @"
import time
from jose import jwt
from bidbrainai_api.settings import get_settings
claims = {
    "sub": "$subId",
    "email": "$Email",
    "role": "authenticated",
    "aud": "authenticated",
    "exp": int(time.time()) + $Days * 86400,
}
print(jwt.encode(claims, get_settings().supabase_jwt_secret.get_secret_value(), algorithm="HS256"))
"@
    $token = ($py | docker compose exec -T api python -) | Select-Object -Last 1
    if ($LASTEXITCODE -ne 0 -or -not $token) { Write-Host "Token minting failed." -ForegroundColor Red; exit 1 }

    $maxAge = $Days * 86400
    Write-Host ""
    Write-Host "Done. To sign in:" -ForegroundColor Green
    Write-Host "  1. Open http://localhost:3000 in the browser"
    Write-Host "  2. Open DevTools (F12) -> Console tab"
    Write-Host "  3. Paste this line and press Enter:"
    Write-Host ""
    Write-Host "document.cookie = `"bb_session=$token; path=/; max-age=$maxAge`"" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  4. Go to http://localhost:3000/dashboard - you are signed in as $Email"
}
finally {
    Pop-Location
}
