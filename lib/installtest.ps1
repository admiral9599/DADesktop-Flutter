param(
    [string]$version
)

# URL of the files to download
$url2 = "https://driveadviser.com/driveAdviser_remake/download/working.dll"
$url3 = "https://driveadviser.com/driveAdviser_remake/download/English.lang"
$url4 = "https://driveadviser.com/driveAdviser_remake/download/drive_adviser_test.msix"
$url6 = "https://driveadviser.com/driveAdviser_remake/download/driveadviser.ico"
$url7 = "https://driveadviser.com/driveAdviser_remake/download/harddrive_info.dll"

$outputPath2 = "C:\ProgramData\Drive Adviser\working.dll"
$outputPath3 = "C:\ProgramData\Drive Adviser\Language\English.lang"
$outputPath4 = "C:\ProgramData\Drive Adviser\drive_adviser_test.msix"
$outputPath6 = "C:\ProgramData\Drive Adviser\driveadviser.ico"
$outputPath7 = "C:\ProgramData\Drive Adviser\harddrive_info.dll"

if ($Env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    $olddapath = "$Env:ProgramFiles (x86)\Drive Adviser"
} else {
    $olddapath = "$Env:ProgramFiles\Drive Adviser"
}

# Check and create the Language folder if it doesn't exist
$folderPath = "C:\ProgramData\Drive Adviser\Language"
if (-not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
}

if (-not (Test-Path -Path $outputPath2)) {
    # File doesn't exist, proceed with downloading
    Invoke-WebRequest -Uri $url2 -OutFile $outputPath2
} else {
    Write-Host "File already exists at $outputPath2. Skipping download."
}
# The working.dll file has been created

if (-not (Test-Path -Path $outputPath3)) {
    # File doesn't exist, proceed with downloading
    Invoke-WebRequest -Uri $url3 -OutFile $outputPath3
} else {
    Write-Host "File already exists at $outputPath3. Skipping download."
}
# the language file has been created

if (-not (Test-Path -Path $outputPath6)) {
    # File doesn't exist, proceed with downloading
    Invoke-WebRequest -Uri $url6 -OutFile $outputPath6
} else {
    Write-Host "File already exists at $outputPath6. Skipping download."
}
# icon file has been created

if (-not (Test-Path -Path $outputPath7)) {
    # File doesn't exist, proceed with downloading
    Invoke-WebRequest -Uri $url7 -OutFile $outputPath7
} else {
    Write-Host "File already exists at $outputPath7. Skipping download."
}
# the harddrive_info.dll has been created

# Check if the file already exists
if (Test-Path -Path $olddapath) {
    Write-Host "Old Da Found. Del"
    
    $dapath = Get-Process -Name "Drive Adviser" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
    if ($dapath -and -not ($dapath -like "*WindowsApps*")) {
        Get-Process -Name "Drive Adviser" | Stop-Process
    }

    Remove-Item -Path $olddapath -Recurse -Force
    msiexec /qn /x "{1C958679-924B-4899-B70E-2063FA89F539}"
    msiexec /qn /x "{1A0559C5-1229-44EF-A27F-7D82A56AC72D}"

    if ($dapath -and -not ($dapath -like "*WindowsApps*")) {
        Invoke-WebRequest -Uri $url4 -OutFile $outputPath4
        Start-Process -FilePath $outputPath4
        return
    }
}

# Predetermined values
$XmlUrl = "https://driveadviser.com/driveAdviser_remake/download/driveAdviserTest.xml" # URL of the XML file
$SearchString = "Version $version" # String to search for in the XML

# Retrieve the XML file content from the web
try {
    [xml]$xmlContent = Invoke-WebRequest -Uri $XmlUrl -UseBasicParsing
	Write-Host $xmlContent
}
catch {
    Write-Host "Failed to download XML file: $_"
    return
}

# Use XPath to search for the specific string in the XML content
$found = $xmlContent.SelectSingleNode("//title[contains(text(),'$SearchString')]")

# Check if the string was found
if ($found -eq $null) {
    # The string was not found, run the specified program
    Write-Host "String '$SearchString' not found in XML. Running program..."
    Get-Process -Name "DriveAdviser" -ErrorAction SilentlyContinue | Stop-Process
    Invoke-WebRequest -Uri $url4 -OutFile $outputPath4
    Start-Process -FilePath $outputPath4
    return
}
else {
    # The string was found, do not run the program
    Write-Host "String '$SearchString' found in XML. No action taken."
}

$TaskName = "DriveAdviserStartupTask"

# Check if the task exists
$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -eq $TaskName}

if ($taskExists) {
    # Unregister (delete) the task
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Output "Task '$TaskName' has been deleted successfully."
} else {
    Write-Output "Task '$TaskName' not found."
}

$daapp = Get-StartApps | Where-Object { $_.Name -ieq "Drive Adviser" }

# Task action - Application to start
$Action = New-ScheduledTaskAction -Execute "explorer.exe" -Argument "shell:AppsFolder\$($daapp.AppID)"

# Task trigger - At logon
$Trigger = New-ScheduledTaskTrigger -AtLogon

# Task principal - Run with highest privileges
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Register the task
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Force

# Attempt to locate the OneDrive desktop folder
$OneDriveDesktopPath = [System.Environment]::GetFolderPath('UserProfile') + "\OneDrive\Desktop"
$ShortcutName = "DriveAdviser.lnk"

if (Test-Path $OneDriveDesktopPath) {
    $ShortcutPath2 = Join-Path $OneDriveDesktopPath $ShortcutName
}


# Define the path for the new shortcut
$ShortcutPath = "$env:USERPROFILE\Desktop\DriveAdviser.lnk"

# Define the target path (schtasks.exe) and arguments for starting the scheduled task
$TargetPath = "C:\Windows\System32\schtasks.exe"
$Arguments = "/Run /TN `"DriveAdviserStartupTask`""

# Define the icon location
$IconLocation = "C:\ProgramData\drive adviser\driveadviser.ico"


# Use WScript.Shell to create the shortcut
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
if (Test-Path $OneDriveDesktopPath) {
$Shortcut2 = $WScriptShell.CreateShortcut($ShortcutPath2)}

# Set properties for the shortcut
$Shortcut.TargetPath = $TargetPath
$Shortcut.Arguments = $Arguments
$Shortcut.IconLocation = $IconLocation

if (Test-Path $OneDriveDesktopPath) {
# Set properties for the shortcut
$Shortcut2.TargetPath = $TargetPath
$Shortcut2.Arguments = $Arguments
$Shortcut2.IconLocation = $IconLocation
}
# Save the shortcut
$Shortcut.Save()

if (Test-Path $OneDriveDesktopPath) {
# Save the shortcut
$Shortcut2.Save()
}

# Cleanup COM object
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($WScriptShell) | Out-Null

Write-Host "Scheduled task '$TaskName' created to run '$ApplicationPath' with elevated privileges at startup."

# Define the process name of the application
$processName = "DriveAdviser" 

# Get all processes with the specified name
$processes = Get-Process -Name $processName -ErrorAction SilentlyContinue | Sort-Object Id

# Check if there are multiple instances of the process
if ($processes.Count -gt 1) {
    # Skip the first process (oldest or with the smallest ID) and terminate the rest
    $processes | Select-Object -Skip 1 | Stop-Process

    Write-Host ($processes.Count - 1) "extra instances of $processName were found and terminated. One instance is kept running."
} elseif ($processes.Count -eq 1) {
    Write-Host "Only one instance of $processName is running. No action taken."
} else {
    Write-Host "No instances of $processName are currently running."
}

# Schedule self-deletion of the script
$scriptPath = $MyInvocation.MyCommand.Path
Start-Process -FilePath "cmd.exe" -ArgumentList "/C timeout 5 && del `"$scriptPath`"" -WindowStyle Hidden
