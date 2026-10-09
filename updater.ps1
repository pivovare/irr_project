
# 1. Указываем папку проекта
$ProjectPath = "C:\mirea\devops\irr_project_1"
Set-Location $ProjectPath

# Переключаемся на ветку main
git switch main

if ($LASTEXITCODE -ne 0) {
    Write-Host "Ошибка переключения на ветку main"
    exit 1
}

# 2. Останавливаем приложение на порту 5000, если оно запущено
$connections = Get-NetTCPConnection -LocalPort 5000 -State Listen `
    -ErrorAction SilentlyContinue

foreach ($connection in $connections) {
    Stop-Process -Id $connection.OwningProcess -Force
}

# 3. Определяем путь к Python в виртуальном окружении
$python = Join-Path $ProjectPath "venv\Scripts\python.exe"

if (-not (Test-Path $python)) {
    Write-Host "Не найден Python в виртуальном окружении: $python"
    exit 1
}

# Проверяем наличие файлов приложения и тестов
$serviceFile = Join-Path $ProjectPath "flask_service.py"
$testFile = Join-Path $ProjectPath "unit_tests.py"

if (-not (Test-Path $serviceFile)) {
    Write-Host "Не найден файл flask_service.py"
    exit 1
}

if (-not (Test-Path $testFile)) {
    Write-Host "Не найден файл unit_tests.py"
    exit 1
}

# 4. Запускаем Flask в отдельном процессе
Start-Process -FilePath $python `
    -ArgumentList "`"$serviceFile`"" `
    -WorkingDirectory $ProjectPath

# 5. Ждём запуска сервера
Start-Sleep -Seconds 3

# 6. Запускаем тесты
& $python $testFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "Тесты завершились с ошибкой"
    exit 1
}

Write-Host "Тестирование завершено"

# Set-Location $PSScriptRoot

# git switch main

# if ($LASTEXITCODE -ne 0) {
#     Write-Host "Ошибка переключения на ветку main"
#     exit 1
# }

# # 2. Останавливаем приложение на порту 5000, если оно запущено
# $connections = Get-NetTCPConnection -LocalPort 5000 -State Listen `
#     -ErrorAction SilentlyContinue

# foreach ($connection in $connections) {
#     Stop-Process -Id $connection.OwningProcess -Force
# }

# # 3. Запускаем Flask в отдельном процессе
# $python = Join-Path $PSScriptRoot "venv\Scripts\python.exe"

# if (-not (Test-Path $python)) {
#     $python = "python"
# }

# Start-Process -FilePath $python `
#     -ArgumentList "flask_service.py" `
#     -WorkingDirectory $PSScriptRoot

# # 4. Ждём запуска сервера
# Start-Sleep -Seconds 3

# # 5. Запускаем тесты
# & $python (Join-Path $PSScriptRoot "unit_tests.py")