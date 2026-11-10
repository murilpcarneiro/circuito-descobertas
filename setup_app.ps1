# Prepara o app Flutter: gera a pasta android/ que falta e liga ao Firebase.
# Rode no PowerShell, dentro da pasta circuito_descobertas:  .\setup_app.ps1
$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\app"

Write-Host "1/4 Gerando arquivos de plataforma (não sobrescreve lib/)..." -ForegroundColor Cyan
flutter create --org br.cesupa --project-name circuito_descobertas --platforms android .

Write-Host "2/4 Baixando dependências..." -ForegroundColor Cyan
flutter pub get

Write-Host "3/4 Instalando FlutterFire CLI..." -ForegroundColor Cyan
dart pub global activate flutterfire_cli

Write-Host "4/4 Conectando ao projeto Firebase (escolha o projeto criado)..." -ForegroundColor Cyan
flutterfire configure --platforms=android --android-package-name=br.cesupa.circuito_descobertas

Write-Host "Pronto! Teste com:  cd app; flutter run" -ForegroundColor Green
