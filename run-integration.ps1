#!/usr/bin/env pwsh

# Build and run the Docker test container for dottie configuration

Write-Host "Building Docker test image..." -ForegroundColor Cyan
docker build -t dottie-test .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Running dottie test container..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
docker run --rm dottie-test
