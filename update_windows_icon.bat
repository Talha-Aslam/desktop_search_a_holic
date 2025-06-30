@echo off
echo HealSearch Windows Icon Update Script
echo =====================================
echo.
echo 1. Make sure you've replaced windows/runner/resources/app_icon.ico with your converted HealSearch logo
echo 2. This script will clean and rebuild your Windows app with the new icon
echo.
pause
echo.
echo Cleaning Flutter build cache...
flutter clean
echo.
echo Building Windows application with new icon...
flutter build windows --release
echo.
echo Done! Your HealSearch logo should now be the Windows application icon.
echo Check the build/windows/runner/Release/ folder for your updated app.
pause
