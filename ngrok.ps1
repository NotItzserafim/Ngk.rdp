# First we download ngrok
Invoke-WebRequest -Uri https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -OutFile ngrok.zip

# Then we unzip it
Expand-Archive -LiteralPath '.\ngrok.zip'

# Set-up and save ngrok authtoken
./ngrok/ngrok.exe authtoken $env:NGROK_AUTH_TOKEN
