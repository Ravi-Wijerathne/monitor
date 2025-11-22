@echo off
REM ==============================================================================
REM System Monitor - Automated Setup and Launch Script
REM ==============================================================================

setlocal enabledelayedexpansion

echo.
echo ===============================================================================
echo                   SYSTEM MONITOR - AUTOMATED SETUP
echo ===============================================================================
echo.

REM Change to script directory
cd /d "%~dp0"

REM ==============================================================================
REM Step 1: Check for Elixir Installation
REM ==============================================================================

echo [1/6] Checking for Elixir installation...
where elixir >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Elixir is not installed!
    echo.
    echo Please install Elixir first:
    echo   1. Open PowerShell as Administrator
    echo   2. Run: choco install elixir -y
    echo   OR download from: https://elixir-lang.org/install.html
    echo.
    pause
    exit /b 1
)
echo [OK] Elixir is installed
elixir --version | findstr "Elixir"

REM ==============================================================================
REM Step 2: Check and Install Mix Dependencies
REM ==============================================================================

echo.
echo [2/6] Checking Mix dependencies...
if not exist "deps\" (
    echo Installing Mix dependencies...
    call mix deps.get
    if !ERRORLEVEL! NEQ 0 (
        echo [ERROR] Failed to install dependencies
        pause
        exit /b 1
    )
    echo [OK] Dependencies installed
) else (
    echo [OK] Dependencies already installed
)

REM ==============================================================================
REM Step 3: Setup Tailwind CSS
REM ==============================================================================

echo.
echo [3/6] Setting up Tailwind CSS...
if not exist "_build\tailwind-x64\tailwind.exe" (
    echo Downloading Tailwind CSS...
    mkdir "_build\tailwind-x64" 2>nul
    
    REM Check if user has manually downloaded it
    if exist "%USERPROFILE%\Downloads\tailwindcss-windows-x64.exe" (
        echo Found Tailwind in Downloads, copying...
        copy "%USERPROFILE%\Downloads\tailwindcss-windows-x64.exe" "_build\tailwind-x64\tailwind.exe" >nul
    ) else (
        echo Please download Tailwind CSS manually from:
        echo https://github.com/tailwindlabs/tailwindcss/releases/download/v3.3.2/tailwindcss-windows-x64.exe
        echo Save it to: %USERPROFILE%\Downloads\
        echo.
        echo Press any key when download is complete...
        pause >nul
        
        if exist "%USERPROFILE%\Downloads\tailwindcss-windows-x64.exe" (
            copy "%USERPROFILE%\Downloads\tailwindcss-windows-x64.exe" "_build\tailwind-x64\tailwind.exe" >nul
        ) else (
            echo [ERROR] Tailwind CSS not found in Downloads folder
            pause
            exit /b 1
        )
    )
)
echo [OK] Tailwind CSS ready

REM ==============================================================================
REM Step 4: Setup ESBuild
REM ==============================================================================

echo.
echo [4/6] Setting up ESBuild...
if not exist "_build\esbuild-windows-x64-0.17.11\esbuild.exe" (
    echo Downloading ESBuild...
    mkdir "_build\esbuild-windows-x64-0.17.11" 2>nul
    
    REM Check if user has manually downloaded it
    if exist "%USERPROFILE%\Downloads\win32-x64-0.17.11.tgz" (
        echo Found ESBuild in Downloads, extracting...
        tar -xzf "%USERPROFILE%\Downloads\win32-x64-0.17.11.tgz" -C "_build\esbuild-windows-x64-0.17.11"
        move "_build\esbuild-windows-x64-0.17.11\package\esbuild.exe" "_build\esbuild-windows-x64-0.17.11\" >nul 2>&1
    ) else (
        echo Installing ESBuild via Mix...
        call mix esbuild.install
    )
)
echo [OK] ESBuild ready

REM ==============================================================================
REM Step 5: Build Assets
REM ==============================================================================

echo.
echo [5/6] Building assets...

REM Create assets directory
if not exist "priv\static\assets" mkdir "priv\static\assets"

REM Build CSS
echo Building CSS...
cd assets
"..\\_build\tailwind-x64\tailwind.exe" -i css\app.css -o ..\priv\static\assets\app.css -c tailwind.config.js >nul 2>&1
cd ..

REM Build JavaScript
echo Building JavaScript...
"_build\esbuild-windows-x64-0.17.11\esbuild.exe" assets\js\app.js --bundle --target=es2017 --outdir=priv\static\assets --external:phoenix --external:phoenix_html --external:phoenix_live_view --external:topbar >nul 2>&1

if exist "priv\static\assets\app.css" (
    echo [OK] Assets built successfully
) else (
    echo [WARNING] Asset build may have issues, but continuing...
)

REM ==============================================================================
REM Step 6: Start Phoenix Server and Open Browser
REM ==============================================================================

echo.
echo [6/6] Starting Phoenix server...
echo.
echo ===============================================================================
echo                    SYSTEM MONITOR IS STARTING
echo ===============================================================================
echo.
echo Dashboard will open automatically at: http://localhost:4000
echo.
echo Press Ctrl+C to stop the server
echo.
echo ===============================================================================
echo.

REM Wait 3 seconds then open browser
start "" cmd /c "timeout /t 3 /nobreak >nul & start http://localhost:4000"

REM Start Phoenix server
call mix phx.server

REM If server stops, pause to show any errors
echo.
echo Server stopped.
pause
