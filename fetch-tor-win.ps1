
Invoke-WebRequest -Uri https://dist.torproject.org/torbrowser/10.5.5/tor-win64-0.4.5.10.zip -OutFile tor.zip

if ((Get-FileHash tor.zip -Algorithm sha512).Hash -ne 'E5DA5899D9F4DDFBD33A8D4AB659659EBC1B47FDFE7BD27681D615792E6B9CB2EBA0BF381E8A7C8D89A3B011523786679883C4ECE492452F5F26E537149999D7' ) { Write-Error 'tor.zip sha512sum mismatch' }

Expand-Archive -Path tor.zip -DestinationPath Tor
