# Automating the PowerShell Script with Task Scheduler

## Prerequisites:

- Administrative privileges on your Windows system.

### Steps:


1. **Create a Task:**
    - Press `Windows+R`, type `taskschd.msc`, and press Enter.
    - In the Task Scheduler window, right-click on "Task Scheduler Library" and select "Create Task."

2. **General Tab:**
    - Give your task a name (e.g., "PowerShell Smart Start").
    - Set the security options as needed (e.g., run as a specific user with administrative privileges).

3. **Triggers Tab:**
    - Click "New" to create a trigger.
    - Set the trigger type to "At startup" or "On system idle."
    - Configure the specific start time or idle time as desired.

4. **Actions Tab:**
    - Click "New" to create an action.
    - Set the action type to "Start a program."
    - In the "Program/script" field, enter the full path to your PowerShell script (e.g: `C:\path\to\your\script.ps1`).
    - Leave the "Add arguments" field blank.
    - In the "Start in" field, specify the directory where your script is located.

5. **Conditions Tab (Optional):**
    - Configure conditions like power supply, idle time, and task start time if needed.
6. **Settings Tab (Optional):**
    - Configure settings like run whether user is logged on or not, run only once, and other advanced settings.
7. **Apply and OK:**
    - Click "Apply" and "OK" to save the task.
