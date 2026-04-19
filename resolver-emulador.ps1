# Script para resolver problemas com Emulador Android

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Script de Resolução - Emulador Android Studio            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$SDKPath = "C:\Users\Joao.Mesquita\AppData\Local\Android\sdk"
$EMUPath = "$SDKPath\emulator\emulator.exe"
$ADBPath = "$SDKPath\platform-tools\adb.exe"

# Passo 1: Verificar se é Administrator
Write-Host "`n[1] Verificando permissões de Administrador..." -ForegroundColor Yellow
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Este script PRECISA rodar como Administrador!" -ForegroundColor Red
    Write-Host "   Clique com botão direito no PowerShell e selecione 'Executar como administrador'" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Permissões OK" -ForegroundColor Green

# Passo 2: Matar processos emuladores travados
Write-Host "`n[2] Encerrando emuladores travados..." -ForegroundColor Yellow
$killed = taskkill /F /IM emulator.exe 2>$null
if ($killed) {
    Write-Host "✓ Emuladores encerrados" -ForegroundColor Green
} else {
    Write-Host "✓ Nenhum emulador ativo" -ForegroundColor Green
}

taskkill /F /IM qemu-system-x86_64.exe 2>$null | Out-Null

# Passo 3: Remover lock files
Write-Host "`n[3] Removendo arquivos de lock..." -ForegroundColor Yellow
Remove-Item -Path "$env:USERPROFILE\.android\avd\*.lock" -Force -ErrorAction SilentlyContinue
Write-Host "✓ Lock files removidos" -ForegroundColor Green

# Passo 4: Resetar ADB
Write-Host "`n[4] Resetando ADB (Android Debug Bridge)..." -ForegroundColor Yellow
& $ADBPath kill-server 2>$null
Start-Sleep -Milliseconds 500
& $ADBPath start-server 2>&1 | Out-Null
Write-Host "✓ ADB reiniciado" -ForegroundColor Green

# Passo 5: Listar emuladores disponíveis
Write-Host "`n[5] Emuladores disponíveis:" -ForegroundColor Yellow
$avds = & $EMUPath -list-avds
if ($avds) {
    $avds | ForEach-Object { Write-Host "   • $_" -ForegroundColor Green }
} else {
    Write-Host "   ❌ Nenhum emulador encontrado!" -ForegroundColor Red
    Write-Host "   Crie um em: Android Studio > Device Manager" -ForegroundColor Yellow
    exit 1
}

# Passo 6: Iniciar emulador
Write-Host "`n[6] Iniciando emulador Medium_Phone_API_36.1..." -ForegroundColor Yellow
Write-Host "   ⏳ Aguarde 30-60 segundos para o Android carregar..." -ForegroundColor Cyan

Start-Process -FilePath $EMUPath -ArgumentList "-avd","Medium_Phone_API_36.1" -WindowStyle Normal

Write-Host "`n" -ForegroundColor Green
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✓ Emulador iniciado!                                     ║" -ForegroundColor Green
Write-Host "║                                                            ║" -ForegroundColor Green
Write-Host "║  Próximos passos:                                         ║" -ForegroundColor Green
Write-Host "║  1. Aguarde o Android completar o boot (1-2 minutos)     ║" -ForegroundColor Green
Write-Host "║  2. Abra um novo PowerShell                               ║" -ForegroundColor Green
Write-Host "║  3. Execute:                                             ║" -ForegroundColor Green
Write-Host "║     cd c:\src\projects\cadastro                          ║" -ForegroundColor Green
Write-Host "║     flutter run                                          ║" -ForegroundColor Green
Write-Host "║                                                            ║" -ForegroundColor Green
Write-Host "║  O app será compilado e instalado automaticamente!        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green

# Passo 7: Aguardar e verificar
Write-Host "`n[7] Aguardando emulador inicializar (até 60 segundos)..." -ForegroundColor Yellow

$timeout = 0
$maxRetries = 60

while ($timeout -lt $maxRetries) {
    Start-Sleep -Seconds 1
    $devices = & $ADBPath devices 2>$null
    if ($devices -match "emulator-\d+\s+device") {
        Write-Host "✓ Emulador detectado e online!" -ForegroundColor Green
        & $ADBPath devices
        break
    }
    $timeout++
    Write-Host -NoNewline "."
}

if ($timeout -eq $maxRetries) {
    Write-Host "`n⚠️ Emulador ainda está carregando. Aguarde mais alguns segundos." -ForegroundColor Yellow
    Write-Host "Se não conectar, reinicie o script." -ForegroundColor Yellow
}

Write-Host "`n[✓] Script concluído!" -ForegroundColor Green
