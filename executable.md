
# Advanced PowerShell Startup Script

## Prerequisites

**Software Requirements**

- Windows 10/11
- PowerShell 5.1 or later
- Anaconda (optional, for Anaconda Navigator)
- Microsoft Office (for Outlook)
- Google Chrome

**Required PowerShell Modules**
- `ps2exe` (for converting script to executable)
    ```powershell
    Install-Module -Name ps2exe -Scope CurrentUser
    ```

## Configuration Options

1. **Modify Wallpaper Directory**

Locate the `WallpaperPath` in the configuration section:
```powershell
Copy$config = @{
    WallpaperPath = "C:\YOUR\ACTUAL\PATH\Pictures\Images"
    # Change this to your preferred wallpaper directory
}
```

2. **Set Gemini API Key**

- Obtain an API key from Google AI Studio
- Replace the empty string in the configuration:

    ```powershell
    Copy$config = @{
        GeminiApiKey = "YOUR_ACTUAL_API_KEY_HERE"
    }
    ```
3. **Customize Startup Applications**
Modify the `Start-Process` commands in `Start-AdvancedStartup` function:
```powershell
Start-Process "Path\To\Your\Outlook.exe"
Start-Process "Path\To\Your\Browser.exe" -ArgumentList "https://yourpreferred.com"
Start-Process "Path\To\Your\Preferred\App.exe"
```

4. **Network Check URLs**
Customize the network check URLs in the configuration:
```powershell
CopyNetworkCheckUrls = @(
    "https://www.google.com",
    "https://www.microsoft.com",
    "https://www.alternative-site.com"
)
```

## Converting to Executable

**Method 1: Using ps2exe Module**

```powershell
# Install ps2exe if not already installed
Install-Module -Name ps2exe -Scope CurrentUser

# Convert script to executable
ps2exe -InputFile "startup-script.ps1" -OutputFile "StartupScript.exe" -noconsole
```

**Method 2: Advanced ps2exe Options**
```powershell
ps2exe -InputFile "startup-script.ps1" -OutputFile "StartupScript.exe" `
       -noconsole `
       -title "My Startup Script" `
       -version "1.0.0.0" `
       -iconFile "path\to\icon.ico"
```

## Adding to Windows Startup
**Option 1: Windows Startup Folder**
1. Press `Win + R`
1. Type `shell:startup`
1. Copy the generated executable to this folder

**Option 2: Task Scheduler**
1. Open Task Scheduler
1. Create a new task
1. Set trigger to "At logon"
1. Set action to run your executable

## Security and Permissions
**Execution Policy**
If you encounter execution policy issues:
```powershell
# Temporarily allow script execution
Set-ExecutionPolicy Bypass -Scope Process

# Or modify for current user
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Logging
The script creates a log at `$env:USERPROFILE\startup_log.txt`

## Customization Tips
**Color Scheme**
Modify colors in the configuration:
```powershell
Colors = @{
    Background = [System.Drawing.SystemColors]::Control
    PrimaryButton = [System.Drawing.Color]::DodgerBlue
    # Adjust other color parameters as needed
}
```

## Error Handling
The script includes error handling with `Show-StyledNotification` to provide user-friendly error messages.

## Privacy and API Usage

- Keep your Gemini API key confidential
- Monitor API usage and set up billing alerts
- Review Google AI Studio's terms of service

## Version History

- v1.0.0: Initial release
- v1.0.1: Added more robust error handling
## Contributing

Contributions are always welcome!

See `contributing.md` for ways to get started.

Please adhere to this project's `code of conduct`.

