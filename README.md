# windows_fix

Powershell script that :</br>

   - Disable telemetry and services
   - Disable CEIP Tasks
   - Blank out AutoLogger
   - Disable windows web search
   - Disable reecent files
   - Disable Activity History
   - Turn off SmartScreen Filter
   - Turn off suggestions
   - Turn off all we can from the privacy settings 
   - Remove extended search bar
   - Remove all apps except calculator, photo and store
   - Remove onedrive
   - Enable dark mode

There's a commented block of code that remove edge too, uncomment it to remove the browser.

 # Before run 

 - open powershell as admin and type: 
 
        Set-ExecutionPolicy Unrestricted -Force
        
 - then launch the script with admin rights
