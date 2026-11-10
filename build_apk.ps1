# Gera o APK de release assinado para enviar ao App Distribution.
$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\app"
flutter build apk --release
$apk = Resolve-Path "build\app\outputs\flutter-apk\app-release.apk"
Write-Host "APK gerado em: $apk" -ForegroundColor Green
explorer.exe /select,"$apk"
