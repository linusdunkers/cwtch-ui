
Invoke-WebRequest -Uri https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-win64-0.4.6.9.zip -OutFile tor.zip

if ((Get-FileHash tor.zip -Algorithm sha512).Hash -ne 'bd99de56ef5ef9516410783ce48d52311093b26e718bf3d0a94efbd754d1cf2d12543f096139d9c289985349d26ee89b2308be5927fa1b410ff4f7f3129d6830' ) { Write-Error 'tor.zip sha512sum mismatch' }

Expand-Archive -Path tor.zip -DestinationPath Tor
