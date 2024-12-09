# PowerShell-SmartStart: Your Personalized Startup Assistant
This script aims to personalize your Windows startup experience by automating tasks and providing insights upon login.

## Features:

- Set a random wallpaper from a specified directory.
- Launch predefined applications automatically.
- Check network connectivity to key websites.
- Monitor CPU, memory, and disk usage.
- Receive a daily greeting powered by the Gemini AI (requires an API key).
- Interact with Gemini AI using a built-in chat interface.
- Log startup report with details and provide a shortcut to access the chat feature.

## Getting Started:

1. Clone this repository to your local machine.

2. **Configuration:** Edit the `$config` variable in `AdvancedStartupScript.ps1` with your desired settings:
    - `WallpaperPath`: Path to your directory containing wallpapers.
    - `GeminiApiKey`: Obtain your free API key from [Google AI Platform](https://console.cloud.google.com/) and enable the "Generative Language Model" API.
    - `NetworkCheckUrls`: List of websites to check for internet connectivity.
    - `LogPath`: Path to store the daily startup report (default: user profile directory).


## Using the Chat Interface:
- Once the script finishes execution, a window will display the daily greeting and system resource report.
- Click the "Chat with Gemini AI" button to launch the chat interface.
- Type your question and press Enter to interact with Gemini AI.

## Requirements:

- PowerShell 5.1 or later
- Administrative privileges (for hotkey registration)
- .NET Framework 4.6 or later (for Windows Forms)
*Disclaimer:* This script utilizes the free tier of the Gemini AI API, which has limitations on usage. Refer to Google's documentation for details.

## Contributing

Contributions are always welcome!

See `contributing.md` for ways to get started.

Please adhere to this project's `code of conduct`.

