$ErrorActionPreference= 'silentlycontinue'
Write-Output "Disable telemetry"
# Disable telemetry and services autostart
Set-Service -Name "DiagTrack" -StartupType disabled
Set-Service -Name "dmwappushservice" -StartupType disabled
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection\ /V AllowTelemetry /T REG_DWORD /D 0 /F
# Disable CEIP Tasks
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" | Disable-ScheduledTask
# Blank out AutoLogger
New-Item "C:\ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl" -ItemType File -Force
# Disable windows web search
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\ /V BingSearchEnabled /T REG_DWORD /D 0 /F
# Disable reecent files
reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /V Start_TrackDocs /T REG_DWORD /D 0 /F
reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /V Start_TrackProgs /T REG_DWORD /D 0 /F
# Disable Activity History
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System\ /V PublishUserActivities /T REG_DWORD /D 0 /F
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System\ /V EnableActivityFeed /T REG_DWORD /D 0 /F 
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System\ /V UploadUserActivities /T REG_DWORD /D 0 /F 
# Turn off SmartScreen Filter
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost\EnableWebContentEvaluation\ /V Enabled /T REG_DWORD /D 0 /F
# Turn off suggestions
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\ /V SystemPaneSuggestionsEnabled /T REG_DWORD /D 0 /F
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\ /V SubscribedContent-338393Enabled /T REG_DWORD /D 0 /F
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\ /V SubscribedContent-353694Enabled /T REG_DWORD /D 0 /F
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\ /V SubscribedContent-353696Enabled /T REG_DWORD /D 0 /F
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\ /V SilentInstalledAppsEnabled /T REG_DWORD /D 0 /F
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\ /V AllowOnlineTips /T REG_DWORD /D 0 /F
# Turn off all we can from the privacy settings 
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy\ /V HasAccepted /T REG_DWORD /D 0 /F
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\InputPersonalization\ /V RestrictImplicitInkCollection /T REG_DWORD /D 1 /F
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\InputPersonalization\ /V RestrictImplicitTextCollection /T REG_DWORD /D 1 /F
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore\ /V HarvestContacts /T REG_DWORD /D 0 /F
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Personalization\Settings\ /V AcceptedPrivacyPolicy /T REG_DWORD /D 0 /F
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy\ /V TailoredExperiencesWithDiagnosticDataEnabled /T REG_DWORD /D 0 /F
reg add HKEY_CURRENT_USER\Control` Panel\International\User` Profile\\ /V HttpAcceptLanguageOptOut /T REG_DWORD /D 1 /F
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo\ /V Enabled /T REG_DWORD /D 0 /F
# Remove extended search bar
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\ /V SearchboxTaskbarMode /T REG_DWORD /D 0 /F 
# Dark theme
reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /V AppsUseLightTheme /T REG_DWORD /D 0 /F 
reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /V SystemUsesLightTheme  /T REG_DWORD /D 0 /F 

Write-Output "Remove apps"
# Remove apps
Get-AppxPackage -AllUsers |
Where-Object {$_.name -notmatch 'Microsoft.VP9VideoExtensions|Microsoft.WebMediaExtensions|Microsoft.WebpImageExtension|Microsoft.Windows.ShellExperienceHost|Microsoft.VCLibs*|Microsoft.DesktopAppInstaller|Microsoft.StorePurchaseApp|Microsoft.Windows.Photos|Microsoft.WindowsStore|Microsoft.XboxIdentityProvider|Microsoft.WindowsCamera|Microsoft.WindowsCalculator|Microsoft.HEIFImageExtension|Microsoft.UI.Xaml*'} |
Remove-AppxPackage 
Get-AppxPackage -allusers *Microsoft.WindowsStore* | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register “$($_.InstallLocation)\AppXManifest.xml”}
Get-AppxPackage -allusers *Microsoft.Windows.Photos* | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register “$($_.InstallLocation)\AppXManifest.xml”}
Get-AppxPackage -allusers *Microsoft.WindowsCalculator* | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register “$($_.InstallLocation)\AppXManifest.xml”}

Write-Output "Removing onedrive"
# Remove onedrive
if ((Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture -eq "64-bit")
{
    #64 bit
    TASKKILL /F /im OneDrive.exe 
    C:\Windows\SysWOW64\OneDriveSetup.exe /uninstall 
}
else
{
    #32 bit
    TASKKILL /F /im OneDrive.exe 
    C:\Windows\System32\OneDriveSetup.exe /uninstall 
}

# Uncomment this block to remove edge too, not suggested.
<# 
Write-Output "Removing edge"
# Remove edge
if ((Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture -eq "64-bit")
{
    #64 bit
    cd "C:\Program Files (x86)\Microsoft\Edge\Application" ; cd 8* ; cd Installer ; .\setup.exe --uninstall --system-level --verbose-logging --force-uninstall
    cd "C:\Program Files (x86)\Microsoft\Edge\Application" ; cd 9* ; cd Installer ; .\setup.exe --uninstall --system-level --verbose-logging --force-uninstall
    cd "C:\Program Files (x86)\Microsoft\Edge\Application" ; cd 1* ; cd Installer ; .\setup.exe --uninstall --system-level --verbose-logging --force-uninstall
}
else
{
    #32 bit
    cd "C:\Program Files\Microsoft\Edge\Application" ; cd 8* ; cd Installer ; .\setup.exe --uninstall --system-level --verbose-logging --force-uninstall
    cd "C:\Program Files\Microsoft\Edge\Application" ; cd 9* ; cd Installer ; .\setup.exe --uninstall --system-level --verbose-logging --force-uninstall
    cd "C:\Program Files\Microsoft\Edge\Application" ; cd 1* ; cd Installer ; .\setup.exe --uninstall --system-level --verbose-logging --force-uninstall
}

Write-Output "Restart your computer to apply these changes"
#>