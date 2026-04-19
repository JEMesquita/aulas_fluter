# 🔧 Diagnóstico e Solução - Emulador Android

## Problemas Encontrados

### 1. ❌ Emuladores Offline
```
emulator-5554   offline
emulator-5556   offline
```
**Causa**: Processos emuladores travados sem fechar corretamente

**Solução**: ✅ Já aplicada
- Matamos os processos com `taskkill /F /IM emulator.exe`
- Removemos lock files em `.android\avd\*.lock`

### 2. ⚠️ Flutter não responde
Tentamos vários comandos:
- `flutter --version` - sem resposta
- `flutter doctor -v` - sem resposta  
- `flutter devices` - sem resposta
- `flutter emulators` - sem resposta

**Possíveis causas**:
- Flutter SDK com problema na instalação
- Variáveis de ambiente não configuradas
- Versão dev do Dart (3.12.0-301.0.dev) pode ter incompatibilidades

## 🛠️ Passos para Resolver

### Passo 1: Verificar Flutter Installation
```bash
# Verifique se o Flutter está realmente instalado
Test-Path "C:\Users\Joao.Mesquita\Desktop\Flutter\flutter\bin\flutter.bat"

# Se falhar, baixe Flutter de https://flutter.dev/docs/get-started/install/windows
```

### Passo 2: Adicionar Flutter ao PATH
```powershell
# Abra PowerShell como ADMINISTRADOR

# Adicione o Flutter ao PATH permanentemente
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\Users\Joao.Mesquita\Desktop\Flutter\flutter\bin",
    [EnvironmentVariableTarget]::Machine
)

# Reinicie o PowerShell/VS Code depois disso
```

### Passo 3: Limpar Cache Flutter
```bash
cd c:\src\projects\cadastro

# Remove cache
flutter clean

# Remove pubspec.lock
Remove-Item pubspec.lock -Force

# Limpa caches do sistema
flutter pub get
```

### Passo 4: Verificar Doctor
```bash
flutter doctor -v
```
Você deve ver saída como:
```
Flutter 3.x.x
Dart 3.x.x
Android SDK 36.1
✓ Android Studio
✓ Emulator support
```

### Passo 5: Iniciar Emulador Manualmente
```bash
# Lista AVDs disponíveis
"C:\Users\Joao.Mesquita\AppData\Local\Android\sdk\emulator\emulator" -list-avds

# Inicia um emulador (vai abrir uma janela)
"C:\Users\Joao.Mesquita\AppData\Local\Android\sdk\emulator\emulator" -avd Medium_Phone_API_36.1

# Espere 30-60 segundos até o Android completar o boot
```

### Passo 6: Conectar Emulador via ADB
```bash
# Em OUTRO PowerShell, verifique se o emulador aparece
"C:\Users\Joao.Mesquita\AppData\Local\Android\sdk\platform-tools\adb" devices

# Deve aparecer como:
# emulator-5554   device
```

### Passo 7: Rodar Aplicação
```bash
cd c:\src\projects\cadastro
flutter run
```

## 🚀 Solução Rápida (Resumo)

Se ainda tiver problemas, tente isto **nesta ordem**:

1. **Fechar tudo** (Android Studio, Emuladores, VS Code)

2. **Abrir PowerShell como ADMINISTRADOR**

3. **Executar**:
```powershell
# Limpar tudo
taskkill /F /IM emulator.exe 2>$null
taskkill /F /IM qemu-system-x86_64.exe 2>$null
Remove-Item "$env:USERPROFILE\.android\avd\*.lock" -Force -ErrorAction SilentlyContinue

# Resetar ADB
& "C:\Users\Joao.Mesquita\AppData\Local\Android\sdk\platform-tools\adb" kill-server

# Esperar
Start-Sleep -Seconds 2

# Iniciar novo emulador (vai abrir uma janela)
& "C:\Users\Joao.Mesquita\AppData\Local\Android\sdk\emulator\emulator" -avd Medium_Phone_API_36.1

# Esperar que carregue completamente (1-2 minutos)
```

4. **Em OUTRO PowerShell**, rodar:
```powershell
cd c:\src\projects\cadastro
flutter clean
flutter pub get
flutter run
```

## 📋 Checklist Final

Antes de rodar `flutter run`:

- [ ] Android Studio instalado e funcionando
- [ ] Android SDK 36.1+ instalado
- [ ] Emulador `Medium_Phone_API_36.1` criado
- [ ] Flutter no PATH (testar: `flutter --version`)
- [ ] Nenhum processo `emulator.exe` rodando antes de iniciar novo
- [ ] ADB respondendo (`adb devices`)

## 🔗 Links Úteis

- [Flutter Installation Guide](https://flutter.dev/docs/get-started/install/windows)
- [Android Emulator Troubleshooting](https://developer.android.com/studio/run/emulator-troubleshoot)
- [Flutter Doctor Documentation](https://flutter.dev/docs/development/tools/flutter-sdk)

## 📞 Se Nada Funcionar

Última opção - reinstale tudo:
1. Baixe Flutter versão stable (não dev): https://flutter.dev/docs/development/tools/sdk/releases
2. Descompacte em `C:\Flutter` (mais simples que Desktop\Flutter\flutter)
3. Execute `flutter doctor` para verificar todas as dependências
4. Rode `flutter create novo_app` para testar com novo projeto
