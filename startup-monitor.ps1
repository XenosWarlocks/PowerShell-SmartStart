# Advanced Startup Script


# Configuration Section
$config = @{
    WallpaperPath = ""  # Replace with your wallpaper directory
    GeminiApiKey = ""  # Replace with your actual Gemini API key
    LogPath = "$env:USERPROFILE\startup_log.txt"  # Changed to user root directory
    NetworkCheckUrls = @(
        "https://www.google.com",
        "https://www.microsoft.com",
        "https://www.cloudflare.com"
    )
}


# Function to Change Wallpaper
function Set-RandomWallpaper {
    try {
        # Get all image files from the specified directory
        $wallpapers = Get-ChildItem -Path $config.WallpaperPath -Include *.jpg, *.jpeg, *.png, *.bmp -Recurse


        if ($wallpapers.Count -eq 0) {
            Write-Warning "No wallpapers found in the specified directory."
            return
        }


        # Select a random wallpaper
        $randomWallpaper = $wallpapers | Get-Random


        # Set wallpaper using Windows API
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
    }
    catch {
        Write-Error "Failed to set wallpaper: $_"
    }
}


# Function to Check Network Connectivity
function Test-NetworkConnectivity {
    $connectivityResults = @()
   
    foreach ($url in $config.NetworkCheckUrls) {
        try {
            $request = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 10
            $connectivityResults += [PSCustomObject]@{
                URL = $url
                Status = "Connected"
                ResponseCode = $request.StatusCode
            }
        }
        catch {
            $connectivityResults += [PSCustomObject]@{
                URL = $url
                Status = "Disconnected"
                ErrorMessage = $_.Exception.Message
            }
        }
    }
   
    return $connectivityResults
}


# Function to Monitor System Resources
function Get-SystemResourceStatus {
    try {
        # CPU Usage
        $cpu = (Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -Average).Average


        # Memory Usage
        $os = Get-WmiObject Win32_OperatingSystem
        $totalMemory = $os.TotalVisibleMemorySize
        $freeMemory = $os.FreePhysicalMemory
        $memoryUsage = [math]::Round((($totalMemory - $freeMemory) / $totalMemory * 100), 2)


        # Disk Space
        $disk = Get-PSDrive C | Select-Object Used, Free, @{Name='PercentFree';Expression={[math]::Round(($_.Free / ($_.Used + $_.Free) * 100), 2)}}


        return [PSCustomObject]@{
            CPUUsage = $cpu
            MemoryUsage = $memoryUsage
            DiskPercentFree = $disk.PercentFree
        }
    }
    catch {
        Write-Error "Failed to retrieve system resources: $_"
        return $null
    }
}


# Function to Get Daily Greeting from Gemini API
function Get-DailyGreeting {
    param(
        [string]$Topic = "morning motivation"
    )


    try {
        if (-not $config.GeminiApiKey) {
            throw "Gemini API key is not set"
        }


        $apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$($config.GeminiApiKey)"
       
        $body = @{
            contents = @{
                role = "user"
                parts = @{
                    text = "Generate a unique, friendly, and inspirational good morning greeting about $Topic. Make it personal, motivational, and exactly 3 sentences long."
                }
            }
        } | ConvertTo-Json -Depth 10


        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType "application/json"
       
        # Extract the generated text from the API response
        $greeting = $response.candidates[0].content.parts[0].text
       
        return $greeting
    }
    catch {
        Write-Warning "Failed to get greeting from Gemini API: $_"
        return "Good morning! Today is a new opportunity to achieve something amazing. Embrace the possibilities that await you."
    }
}


# Function to Interact with Gemini AI
function Start-GeminiChat {
    try {
        if (-not $config.GeminiApiKey) {
            [System.Windows.Forms.MessageBox]::Show("Please set your Gemini API key in the configuration.", "API Key Required")
            return
        }


        # Prompt user for input
        Add-Type -AssemblyName Microsoft.VisualBasic
        $userInput = [Microsoft.VisualBasic.Interaction]::InputBox("Ask Gemini a question:", "Gemini AI Chat")


        if (-not [string]::IsNullOrWhiteSpace($userInput)) {
            $apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$($config.GeminiApiKey)"
           
            $body = @{
                contents = @{
                    role = "user"
                    parts = @{
                        text = $userInput
                    }
                }
            } | ConvertTo-Json -Depth 10


            $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType "application/json"
           
            # Extract the generated text from the API response
            $aiResponse = $response.candidates[0].content.parts[0].text


            # Show response in a message box
            [System.Windows.Forms.MessageBox]::Show($aiResponse, "Gemini AI Response")
        }
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", "Gemini AI Error")
    }
}


# Main Startup Script
function Start-AdvancedStartup {
    try {
        # Ensure required assemblies are loaded
        Add-Type -AssemblyName System.Windows.Forms


        # Change Wallpaper
        Set-RandomWallpaper


        # Launch Applications
        Start-Process "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
        Start-Process "C:\Program Files\Google\Chrome\Application\chrome.exe" -ArgumentList "https://www.bing.com"
        Start-Process "$env:UserProfile\anaconda3\Scripts\anaconda-navigator.exe"


        # Wait for applications to start
        Start-Sleep -Seconds 10


        # Perform Checks
        $networkStatus = Test-NetworkConnectivity
        $resourceStatus = Get-SystemResourceStatus
        $dailyGreeting = Get-DailyGreeting


        # Prepare Startup Log
        $logContent = @"
Daily Startup Report


Greeting: $dailyGreeting


Network Connectivity:
$($networkStatus | Format-Table -AutoSize | Out-String)


System Resources:
CPU Usage: $($resourceStatus.CPUUsage)%
Memory Usage: $($resourceStatus.MemoryUsage)%
Disk Free: $($resourceStatus.DiskPercentFree)%


Tip: Press Ctrl+G to open Gemini AI Chat
"@


        # Log the results
        $logContent | Out-File $config.LogPath


        # Create a form for daily greeting and interaction
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Daily Startup Report"
        $form.Size = New-Object System.Drawing.Size(400,300)
        $form.StartPosition = "CenterScreen"


        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Multiline = $true
        $textBox.ReadOnly = $true
        $textBox.Dock = "Fill"
        $textBox.Text = $logContent


        $form.Controls.Add($textBox)


        # Add a button to launch Gemini Chat
        $chatButton = New-Object System.Windows.Forms.Button
        $chatButton.Text = "Chat with Gemini AI"
        $chatButton.Dock = "Bottom"
        $chatButton.Add_Click({
            Start-GeminiChat
        })
        $form.Controls.Add($chatButton)


        # Setup global hotkey for Gemini Chat
        $hook = @"
[DllImport("user32.dll")]
public static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);
"@
        $type = Add-Type -MemberDefinition $hook -Name win32 -Namespace system -PassThru
        $type::RegisterHotKey([System.IntPtr]::Zero, 1, 0x2, 0x47) # Ctrl+G


        # Show the form
        $form.ShowDialog()
    }
    catch {
        # Display error in a message box
        [System.Windows.Forms.MessageBox]::Show("An error occurred during startup: $_", "Startup Script Error")
    }
}


# Execute the startup script
Start-AdvancedStartup

