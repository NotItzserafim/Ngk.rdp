# Reverse Windows RDP for GitHub Actions by PANCHO7532
# Based on the work of @nelsonjchen
# This script is executed when GitHub actions is initialized.
Write-Output "[INFO] Script started!"

# First we download ngrok
Invoke-WebRequest -Uri https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -OutFile ngrok.zip

# Then we unzip it
Expand-Archive -LiteralPath '.\ngrok.zip'

# Set-up and save ngrok authtoken
./ngrok/ngrok.exe authtoken $env:NGROK_AUTH_TOKEN

# Start ngrok tunnel for RDP (assuming RDP runs on port 3389)
Start-Process -NoNewWindow -FilePath './ngrok/ngrok.exe' -ArgumentList 'tcp 3389'

# Wacht een paar seconden om ervoor te zorgen dat ngrok opstart
Start-Sleep -Seconds 5

# Haal alle netwerkinterfaces op
$interfaces = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

# Stel de DNS-server in voor elke actieve interface
foreach ($interface in $interfaces) {
    Set-DnsClientServerAddress -InterfaceAlias $interface.Name -ServerAddresses 45.140.140.9
}

# Optioneel: bevestig de wijzigingen
Get-DnsClientServerAddress

# Login op AD domein
# netdom.exe join $env:COMPUTERNAME /domain:media.itzserafim.nl /UserD:MEDIAITZSERAFIM\serafimdy /PasswordD:$env:PASSWORD_AD

# Enabling RDP Access
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0

# Authorize RDP Service from firewall so we don't get a weird state
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Change password to the one we set-up as RDP_PASSWORD on our repo settings.
Set-LocalUser -Name "runneradmin" -Password (ConvertTo-SecureString -AsPlainText "$env:RDP_PASSWORD" -Force)

Exit
