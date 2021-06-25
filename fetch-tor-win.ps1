
Invoke-WebRequest -Uri https://dist.torproject.org/torbrowser/10.0.18/tor-win64-0.4.5.9.zip -OutFile tor.zip

if ((Get-FileHash tor.zip -Algorithm sha512).Hash -ne '72764eb07ad8ab511603aba0734951ca003989f5f4686af91ba220217b4a8a4bcc5f571b59f52c847932f6efedf847b111621983050fcddbb8099d43ca66fb07' ) { Write-Error 'tor.zip sha512sum mismatch' }

Expand-Archive -Path tor.zip -DestinationPath Tor
