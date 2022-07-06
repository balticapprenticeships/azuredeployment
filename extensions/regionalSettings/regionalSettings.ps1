################################################################
# Script to define regional settings on Azure Virtual machines #
# Author: Chris Langford                                       #
# Version: 1.0.0                                               #
################################################################

#variables
$regionalsettingsURL = "https://raw.githubusercontent.com/balticapprenticeships/azure-extensions/master/extensions/regionalSettings/gbRegional.xml"
$RegionalSettings = "D:\gbRegion.xml"


#downdload regional settings file
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile($regionalsettingsURL,$RegionalSettings)


# Set Locale, language etc. 
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$RegionalSettings`""

# Set languages/culture. Not needed perse.
Set-WinSystemLocale en-GB
Set-WinUserLanguageList -LanguageList en-GB -Force
Set-WinUILanguageOverride -Language en-GB
Set-Culture -CultureInfo en-GB
Set-WinHomeLocation -GeoId 242
Set-TimeZone -Name "GMT Standard Time"

# restart virtual machine to apply regional settings to current user. You could also do a logoff and login.
Start-sleep -Seconds 30
Restart-Computer