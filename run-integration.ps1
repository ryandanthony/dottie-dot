#!/usr/bin/env pwsh
param(
    [switch]$NoCache
)

# Build and run the Docker test container for dottie configuration

$buildArgs = @("build", "-t", "dottie-test")
if ($NoCache) {
    Write-Host "Building Docker test image (no cache)..." -ForegroundColor Cyan
    $buildArgs += "--no-cache"
} else {
    Write-Host "Building Docker test image..." -ForegroundColor Cyan
}
$buildArgs += "."
docker @buildArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Running dottie test container..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
docker run --rm dottie-test
