$ProjectPath = "C:\mirea\devops\irr_project_1"
Set-Location $ProjectPath

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

# 3. Запускаем Flask в отдельном процессе
$python = Join-Path $PSScriptRoot "venv\Scripts\python.exe"

if (-not (Test-Path $python)) {
    $python = "python"
}

Start-Process -FilePath $python `
    -ArgumentList "flask_service.py" `
    -WorkingDirectory $PSScriptRoot

# 4. Ждём запуска сервера
Start-Sleep -Seconds 3

# 5. Запускаем тесты
& $python (Join-Path $PSScriptRoot "unit_tests.py")