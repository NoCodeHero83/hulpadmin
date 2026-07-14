#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy hulp_admin a Vercel via REST API sin usar el CLI de Vercel.
.DESCRIPTION
    Sube todos los archivos de build/web/ a Vercel usando la API, crea el deployment
    en producción y hace polling hasta que esté listo.
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
Write-Host "Deploy hulp_admin a Vercel via REST API" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# Validar que el directorio de build exista
if (-not (Test-Path $BuildDir)) {
    Write-Host "❌ Error: El directorio $BuildDir no existe." -ForegroundColor Red
    Write-Host "Primero debes compilar con: flutter build web --release" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✓ Directorio de build encontrado: $(Resolve-Path $BuildDir)" -ForegroundColor Green

# Copiar vercel.json al directorio de build
$vercelJsonSource = ".\vercel.json"
$vercelJsonDest = "$BuildDir\vercel.json"

if (Test-Path $vercelJsonSource) {
    Copy-Item $vercelJsonSource $vercelJsonDest -Force
    Write-Host "✓ vercel.json copiado a build/web/" -ForegroundColor Green
}

# Función para calcular SHA1
function Get-FileSHA1 {
    param([string]$FilePath)
    $sha1 = [System.Security.Cryptography.SHA1]::Create()
    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
    $hash = $sha1.ComputeHash($fileBytes)
    $hashString = [System.BitConverter]::ToString($hash).Replace("-", "").ToLower()
    return $hashString
}

# Recolectar archivos para subir
Write-Host "`n📦 Recolectando archivos..." -ForegroundColor Cyan
$files = @()
$filesList = Get-ChildItem -Path $BuildDir -Recurse -File

foreach ($file in $filesList) {
    $relativePath = $file.FullName.Substring($([System.IO.Path]::GetFullPath($BuildDir)).Length + 1).Replace('\', '/')
    $sha1 = Get-FileSHA1 -FilePath $file.FullName
    $size = $file.Length

    $files += @{
        "file" = $relativePath
        "sha"  = $sha1
        "size" = $size
    }

    Write-Host "  • $relativePath ($size bytes)" -ForegroundColor Gray
}

Write-Host "`nTotal de archivos: $($files.Count)" -ForegroundColor Green

# Paso 1: Subir archivos a Vercel
Write-Host "`n📤 Subiendo archivos a Vercel..." -ForegroundColor Cyan

foreach ($fileObj in $files) {
    $filePath = Join-Path $BuildDir ($fileObj.file.Replace('/', '\'))
    $fileContent = [System.IO.File]::ReadAllBytes($filePath)

    $uri = "https://api.vercel.com/v2/files?projectId=$ProjectId&teamId=$TeamId"

    try {
        $request = [System.Net.HttpWebRequest]::CreateHttp($uri)
        $request.Method = "PUT"
        $request.Headers.Add("Authorization", "Bearer $Token")
        $request.ContentLength = $fileObj.size
        $request.Headers.Add("x-vercel-digest", $fileObj.sha)
        $request.ContentType = "application/octet-stream"

        $requestStream = $request.GetRequestStream()
        $requestStream.Write($fileContent, 0, $fileContent.Length)
        $requestStream.Close()

        $response = $request.GetResponse()
        $response.Close()

        Write-Host "  ✓ $($fileObj.file)" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ Error subiendo $($fileObj.file): $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Paso 2: Crear el deployment
Write-Host "`n🚀 Creando deployment en producción..." -ForegroundColor Cyan

$deploymentBody = @{
    "name"      = "hulp-admin-prod"
    "projectId" = $ProjectId
    "target"    = "production"
    "files"     = $files
} | ConvertTo-Json -Depth 10

try {
    $uri = "https://api.vercel.com/v13/deployments?teamId=$TeamId"

    $request = [System.Net.HttpWebRequest]::CreateHttp($uri)
    $request.Method = "POST"
    $request.Headers.Add("Authorization", "Bearer $Token")
    $request.ContentType = "application/json"

    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($deploymentBody)
    $request.ContentLength = $bodyBytes.Length

    $requestStream = $request.GetRequestStream()
    $requestStream.Write($bodyBytes, 0, $bodyBytes.Length)
    $requestStream.Close()

    $response = $request.GetResponse()
    $responseStream = $response.GetResponseStream()
    $streamReader = [System.IO.StreamReader]::new($responseStream)
    $responseContent = $streamReader.ReadToEnd()
    $streamReader.Close()
    $response.Close()

    $deployment = $responseContent | ConvertFrom-Json
    $deploymentId = $deployment.id

    Write-Host "✓ Deployment creado: $deploymentId" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error creando deployment: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Paso 3: Polling hasta que esté listo
Write-Host "`n⏳ Esperando a que el deployment esté listo..." -ForegroundColor Cyan

$maxAttempts = 60
$attempt = 0
$deploymentReady = $false

while ($attempt -lt $maxAttempts -and -not $deploymentReady) {
    Start-Sleep -Seconds 2
    $attempt++

    try {
        $uri = "https://api.vercel.com/v13/deployments/$deploymentId?teamId=$TeamId"

        $request = [System.Net.HttpWebRequest]::CreateHttp($uri)
        $request.Method = "GET"
        $request.Headers.Add("Authorization", "Bearer $Token")

        $response = $request.GetResponse()
        $responseStream = $response.GetResponseStream()
        $streamReader = [System.IO.StreamReader]::new($responseStream)
        $responseContent = $streamReader.ReadToEnd()
        $streamReader.Close()
        $response.Close()

        $status = $responseContent | ConvertFrom-Json
        $state = $status.state

        switch ($state) {
            "READY" {
                $deploymentReady = $true
                Write-Host "✓ Deployment listo" -ForegroundColor Green
            }
            "ERROR" {
                Write-Host "❌ Error en deployment" -ForegroundColor Red
                exit 1
            }
            default {
                Write-Host "  $state... (intento $attempt/$maxAttempts)" -ForegroundColor Gray
            }
        }
    }
    catch {
        Write-Host "⚠️ Error consultando estado: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

if (-not $deploymentReady) {
    Write-Host "❌ Timeout esperando el deployment" -ForegroundColor Red
    exit 1
}

# Resultado final
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "✅ Deploy completado exitosamente" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""
Write-Host "Deployment ID: $deploymentId" -ForegroundColor Cyan
Write-Host "URL de producción: https://hulpweb.com/" -ForegroundColor Cyan
Write-Host ""
Write-Host "Los cambios están vivos en: https://hulpweb.com/" -ForegroundColor Yellow
