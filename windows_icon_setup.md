# HealSearch Windows Icon Setup

## Instructions to Replace Windows Application Icon:

1. Convert your healsearch_logo.png to ICO format using:
   - Online: https://convertio.co/png-ico/
   - Make sure to include multiple sizes: 16x16, 32x32, 48x48, 64x64, 128x128, 256x256

2. Replace the file:
   - Save your converted ICO file as: windows/runner/resources/app_icon.ico
   - This will overwrite the existing app_icon.ico

3. Clean and rebuild:
   - flutter clean
   - flutter build windows

## Current Configuration:
- Icon path: windows/runner/resources/app_icon.ico
- Referenced in: windows/runner/Runner.rc (line 55)
- Resource ID: IDI_APP_ICON

Your HealSearch logo will then appear as:
- Window title bar icon
- Taskbar icon
- Alt+Tab icon
- Windows Explorer icon
- Desktop shortcut icon
