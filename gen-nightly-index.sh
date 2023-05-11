#!/bin/bash

# A basic script to redirect https://build.openprivacy.ca/cwtch-nightly.html to the latest nightly.
# In the future we may want to make this page nicer...
echo "<html><head><title>Cwtch Nightly</title><meta http-equiv=\"refresh\" content=\"0;URL='https://build.openprivacy.ca/files/$1'\" /> s</head></html>" > cwtch-nightly.html