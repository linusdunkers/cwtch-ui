
Invoke-WebRequest -Uri https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-win64-0.4.7.8.zip -OutFile tor.zip

if ((Get-FileHash tor.zip -Algorithm sha512).Hash -ne '5b8f900a37f6e90d7a945b3903d769383c7478042cb43b2105d2374186e1a536f1a4758a2823d1d5be71d53a81dcfd8243293e04f82812d355983df322823cf4' ) { Write-Error 'tor.zip sha512sum mismatch' }

Expand-Archive -Path tor.zip -DestinationPath Tor
