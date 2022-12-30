$Env:VERSION = type LIBCWTCH-GO.version
echo $Env:VERSION

# This should automatically fail on error...
Invoke-WebRequest -Uri https://build.openprivacy.ca/files/libCwtch-go-$Env:VERSION/libCwtch.dll -OutFile windows/libCwtch.dll

#Invoke-WebRequest -Uri https://build.openprivacy.ca/files/libCwtch-go-$Env:VERSION/cwtch.aar -OutFile android/cwtch/cwtch.aar
#Invoke-WebRequest -Uri https://build.openprivacy.ca/files/libCwtch-go-$Env:VERSION/libCwtch.so -Outfile linux/libCwtch.so
