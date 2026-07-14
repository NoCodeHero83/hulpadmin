#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy hulp_admin a Vercel via REST API - Versión mejorada
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Token = $env:VERCEL_TOKEN,

    [Parameter(Mandatory=$false)]
    [string]$ProjectId = "prj_XpyBBRNE88b2hs3zOz1cObI2wRSA",

    [Parameter(Mandatory=$false)]
    [string]$TeamId = "team_S0ZmN8rA23bzqapDt6QMTe7o",

    [Parameter(Mandatory=$false)]
    [string]$BuildDir = ".\build\web"
)

$ErrorActionPreference = "Stop"

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🚀 Deploy hulp_admin a Vercel" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# Validar build
if (-not (Test-Path $BuildDir)) {
    Write-Host "❌ Error: Directorio $BuildDir no existe" -ForegroundColor Red
    exit 1
}

Write-Host "`n✓ Build encontrado en: $(Resolve-Path $BuildDir)" -ForegroundColor Green

# Copiar vercel.json
$vercelJsonSource = ".\vercel.json"
$vercelJsonDest = "$BuildDir\vercel.json"
if (Test-Path $vercelJsonSource) {
    Copy-Item $vercelJsonSource $vercelJsonDest -Force
    Write-Host "✓ vercel.json copiado" -ForegroundColor Green
}

# Recolectar archivos
Write-Host "`n📦 Recolectando archivos..." -ForegroundColor Cyan
$files = @()
$filesList = Get-ChildItem -Path $BuildDir -Recurse -File

foreach ($file in $filesList) {
    $relativePath = $file.FullName.Substring($([System.IO.Path]::GetFullPath($BuildDir)).Length + 1).Replace('\', '/')
    $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)

    # Convertir a base64
    $base64Data = [System.Convert]::ToBase64String($fileBytes)

    $files += @{
        "file" = $relativePath
        "data" = $base64Data
    }

    Write-Host "  • $relativePath" -ForegroundColor Gray
}

Write-Host "`nTotal: $($files.Count) archivos" -ForegroundColor Green

# Crear deployment
Write-Host "`n🚀 Creando deployment en Vercel..." -ForegroundColor Cyan

$deploymentBody = @{
    "name"      = "hulp-admin-prod"
    "projectId" = $ProjectId
    "target"    = "production"
    "files"     = $files
} | ConvertTo-Json -Depth 20

try {
    $response = Invoke-WebRequest `
        -Uri "https://api.vercel.com/v13/deployments?teamId=$TeamId" `
        -Method POST `
        -Headers @{
            "Authorization" = "Bearer $Token"
            "Content-Type"  = "application/json"
        } `
        -Body $deploymentBody `
        -ErrorAction Stop

    $deployment = $response.Content | ConvertFrom-Json
    $deploymentId = $deployment.id

    Write-Host "✓ Deployment creado: $deploymentId" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $errorContent = $reader.ReadToEnd()
        Write-Host "Respuesta: $errorContent" -ForegroundColor Red
    }
    exit 1
}

# Polling
Write-Host "`n⏳ Esperando deployment..." -ForegroundColor Cyan

$maxAttempts = 60
$attempt = 0

while ($attempt -lt $maxAttempts) {
    Start-Sleep -Seconds 2
    $attempt++

    try {
        $statusResponse = Invoke-WebRequest `
            -Uri "https://api.vercel.com/v13/deployments/$deploymentId?teamId=$TeamId" `
            -Method GET `
            -Headers @{"Authorization" = "Bearer $Token"} `
            -ErrorAction Stop

        $status = $statusResponse.Content | ConvertFrom-Json
        $state = $status.state

        if ($state -eq "READY") {
            Write-Host "✓ Deployment listo" -ForegroundColor Green
            break
        } elseif ($state -eq "ERROR") {
            Write-Host "❌ Error en deployment" -ForegroundColor Red
            exit 1
        } else {
            Write-Host "  $state... (intento $attempt/$maxAttempts)" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "⚠️ Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Resultado
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "✅ DEPLOY COMPLETADO" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""
Write-Host "📱 URL: https://hulpweb.com/" -ForegroundColor Cyan
Write-Host "ID: $deploymentId" -ForegroundColor Gray
