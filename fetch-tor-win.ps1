
Invoke-WebRequest -Uri https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-win64-0.4.6.5.zip -OutFile tor.zip

if ((Get-FileHash tor.zip -Algorithm sha512).Hash -ne '7917561a7a063440a1ddfa9cb544ab9ffd09de84cea3dd66e3cc9cd349dd9f85b74a522ec390d7a974bc19b424c4d53af60e57bbc47e763d13cab6a203c4592f' ) { Write-Error 'tor.zip sha512sum mismatch' }

Expand-Archive -Path tor.zip -DestinationPath Tor
