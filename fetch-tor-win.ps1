
Invoke-WebRequest -Uri https://www.torproject.org/dist/torbrowser/10.0.16/tor-win32-0.4.5.7.zip -OutFile tor.zip

if ((Get-FileHash tor.zip -Algorithm sha512).Hash -ne '2b7d683f036d0fec149f1d2bdfcf5b7ef4c337005a2b685c056b00047fdb2b57d4c25b8559ad7ef5c7a030b273934be82a9f83ef6e391f5d7d13d8d6c83e8048' ) { Write-Error 'tor.zip sha512sum mismatch' }

Expand-Archive -Path tor.zip -DestinationPath Tor
