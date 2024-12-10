# Advanced Startup Script
# Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# Configuration Section
$config = @{
    WallpaperPath = "C:\Users\Pictures\Images"  # Set wallpaper directory
    GeminiApiKey = ""  # Set your Gemini API key here
    LogPath = "$env:USERPROFILE\startup_log.txt"  # Log file location
    NetworkCheckUrls = @(
        "https://www.google.com",
        "https://www.microsoft.com",
        "https://www.cloudflare.com"
    )
    # Color Scheme using direct color definition
    Colors = @{
        Background = [System.Drawing.SystemColors]::Control
        PrimaryButton = [System.Drawing.Color]::DodgerBlue
        SecondaryButton = [System.Drawing.Color]::MediumSeaGreen
        TextColor = [System.Drawing.Color]::FromName("DarkSlateGray")
    }
}


Add-Type -Path "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Windows.Forms.dll"


# Helper Function: Display Styled Notifications
function Show-StyledNotification {
    param (
        [string]$Message,
        [string]$Title = "Notification",
        [int]$Width = 500,
        [int]$Height = 400
    )


    # Create main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size($Width, $Height)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.SystemColors]::Control
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.MaximizeBox = $false


    # Rich Text Box for scrollable content
    $richTextBox = New-Object System.Windows.Forms.RichTextBox
    $richTextBox.Dock = [System.Windows.Forms.DockStyle]::Fill
    $richTextBox.ReadOnly = $true
    $richTextBox.BackColor = [System.Drawing.Color]::White
    $richTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $richTextBox.Text = $Message


    # Close button with improved styling
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Text = "Close"
    $closeButton.BackColor = [System.Drawing.Color]::DodgerBlue
    $closeButton.ForeColor = [System.Drawing.Color]::White
    $closeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $closeButton.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $closeButton.Height = 40
    $closeButton.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 10)
    $closeButton.Add_Click({ $form.Close() })


    # Add controls
    $form.Controls.Add($richTextBox)
    $form.Controls.Add($closeButton)


    # Show the form
    $form.ShowDialog()
}




# Function to Change Wallpaper
function Set-RandomWallpaper {
    try {
        $wallpapers = Get-ChildItem -Path $config.WallpaperPath -Include *.jpg, *.jpeg, *.png, *.bmp -Recurse


        if (-not $wallpapers) {
            Show-Notification "No wallpapers found in the specified directory." "Wallpaper Change Failed"
            return
        }


        $randomWallpaper = $wallpapers | Get-Random


        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        public class Wallpaper {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
        }
"@
        $SPI_SETDESKWALLPAPER = 0x0014
        [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $randomWallpaper.FullName, 0x01)


        Write-Host "Wallpaper set to: $($randomWallpaper.Name)"
    } catch {
        Write-Error "Failed to set wallpaper: $_"
        Show-Notification "Error setting wallpaper: $_" "Error"
    }
}


# Function to Check Network Connectivity
function Test-NetworkConnectivity {
    $results = foreach ($url in $config.NetworkCheckUrls) {
        try {
            $response = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 10
            [PSCustomObject]@{
                URL = $url
                Status = "Connected"
                ResponseCode = $response.StatusCode
            }
        } catch {
            [PSCustomObject]@{
                URL = $url
                Status = "Disconnected"
                ErrorMessage = $_.Exception.Message
            }
        }
    }
    return $results
}


# Function to Monitor System Resources
function Get-SystemResourceStatus {
    try {
        $cpu = (Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -Average).Average
        $os = Get-WmiObject Win32_OperatingSystem
        $memoryUsage = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 2)
        $disk = Get-PSDrive C | Select-Object Used, Free, @{Name='PercentFree';Expression={[math]::Round(($_.Free / ($_.Used + $_.Free)) * 100, 2)}}


        [PSCustomObject]@{
            CPUUsage = $cpu
            MemoryUsage = $memoryUsage
            DiskFreePercentage = $disk.PercentFree
        }
    } catch {
        Write-Error "Failed to retrieve system resources: $_"
        return $null
    }
}


# Function to Get Daily Greeting
function Get-DailyGreeting {
    param (
        [string]$Topic = "morning motivation"
    )
    try {
        if (-not $config.GeminiApiKey) {
            throw "Gemini API key is not set."
        }


        $apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$($config.GeminiApiKey)"
        $body = @{ contents = @{ role = "user"; parts = @{ text = "Generate a motivational greeting about $Topic." } } } | ConvertTo-Json -Depth 10


        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType "application/json"
        return $response.candidates[0].content.parts[0].text
    } catch {
        Write-Warning "Failed to get greeting: $_"
        return "Good morning! Today is a new opportunity to achieve greatness."
    }
}


# Function to Interact with Gemini AI
function Start-GeminiChat {


    # Input form
    $inputForm = New-Object System.Windows.Forms.Form
    $inputForm.Text = "Gemini AI Chat"
    $inputForm.Size = New-Object System.Drawing.Size(500, 250)
    $inputForm.StartPosition = "CenterScreen"
    $inputForm.BackColor = [System.Drawing.SystemColors]::Control


    # Label
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Ask Gemini a question:"
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $label.Size = New-Object System.Drawing.Size(460, 30)
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 12)


    # Input text box
    $inputTextBox = New-Object System.Windows.Forms.TextBox
    $inputTextBox.Multiline = $true
    $inputTextBox.Location = New-Object System.Drawing.Point(20, 60)
    $inputTextBox.Size = New-Object System.Drawing.Size(460, 100)
    $inputTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)


    # Send button
    $sendButton = New-Object System.Windows.Forms.Button
    $sendButton.Text = "Send to Gemini"
    $sendButton.Location = New-Object System.Drawing.Point(200, 170)
    $sendButton.Size = New-Object System.Drawing.Size(100, 40)
    $sendButton.BackColor = [System.Drawing.Color]::MediumSeaGreen
    $sendButton.ForeColor = [System.Drawing.Color]::White
    $sendButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $sendButton.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 10)


    # Button click event
    $sendButton.Add_Click({
        $userInput = $inputTextBox.Text.Trim()
       
        if ([string]::IsNullOrWhiteSpace($userInput)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter a question.", "Input Required")
            return
        }


        try {
            # Check API Key
            if (-not $config.GeminiApiKey) {
                [System.Windows.Forms.MessageBox]::Show("Please set the Gemini API key in the configuration.", "API Key Missing")
                return
            }


            # Gemini API Call
            $apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$($config.GeminiApiKey)"
            $body = @{
                contents = @{
                    role = "user"
                    parts = @{ text = $userInput }
                }
            } | ConvertTo-Json -Depth 10


            $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType "application/json"
            $aiResponse = $response.candidates[0].content.parts[0].text


            # Close input form
            $inputForm.Close()


            # Show response in scrollable notification
            Show-StyledNotification -Message $aiResponse -Title "Gemini AI Response"
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Error: $_", "Gemini AI Error")
        }
    })


    # Add controls to the form
    $inputForm.Controls.Add($label)
    $inputForm.Controls.Add($inputTextBox)
    $inputForm.Controls.Add($sendButton)


    # Show the input form
    $inputForm.ShowDialog()
}


# Main Startup Script
function Start-AdvancedStartup {
    try {
        Set-RandomWallpaper


        Start-Process "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
        Start-Process "C:\Program Files\Google\Chrome\Application\chrome.exe" -ArgumentList "https://www.google.com"
        Start-Process "$env:UserProfile\anaconda3\Scripts\anaconda-navigator.exe"


        Start-Sleep -Seconds 10


        $networkStatus = Test-NetworkConnectivity
        $resourceStatus = Get-SystemResourceStatus
        $dailyGreeting = Get-DailyGreeting


        $logContent = @"
Daily Startup Report


Greeting: $dailyGreeting


Network Connectivity:
$($networkStatus | Format-Table -AutoSize | Out-String)


System Resources:
CPU Usage: $($resourceStatus.CPUUsage)%
Memory Usage: $($resourceStatus.MemoryUsage)%
Disk Free: $($resourceStatus.DiskFreePercentage)%
"@


        $logContent | Out-File $config.LogPath


        # Enhanced Form Styling
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Daily Startup Report"
        $form.Size = New-Object System.Drawing.Size(500, 400)
        $form.StartPosition = "CenterScreen"
        $form.BackColor = [System.Drawing.SystemColors]::Control


        # Rich Text Box for log content
        $textBox = New-Object System.Windows.Forms.RichTextBox
        $textBox.Multiline = $true
        $textBox.ReadOnly = $true
        $textBox.Dock = "Fill"
        $textBox.Text = $logContent
        $textBox.BackColor = [System.Drawing.Color]::White
        $textBox.Font = New-Object System.Drawing.Font("Consolas", 10)


        # Chat Button with Modern Design
        $chatButton = New-Object System.Windows.Forms.Button
        $chatButton.Text = "Chat with Gemini AI"
        $chatButton.Dock = "Bottom"
        $chatButton.Height = 50
        $chatButton.BackColor = [System.Drawing.Color]::DodgerBlue
        $chatButton.ForeColor = [System.Drawing.Color]::White
        $chatButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $chatButton.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 12)
        $chatButton.Add_Click({ Start-GeminiChat })


        # Add controls
        $form.Controls.Add($textBox)
        $form.Controls.Add($chatButton)


        # Show the form
        $form.ShowDialog()
    } catch {
        Show-StyledNotification "An error occurred during startup: $_" "Startup Error"
    }
}


# Execute the startup script
Start-AdvancedStartup


# Install-Module -Name ps2exe -Scope CurrentUser
# ps2exe -InputFile "startup-backup.ps1" -OutputFile "Startup.exe" -noconsole





