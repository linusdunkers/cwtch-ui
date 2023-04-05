#!/bin/sh
# Start Cwtch with Tails
exec env CWTCH_TAILS=true LD_LIBRARY_PATH=~/.local/lib/cwtch/:~/.local/lib/cwtch/Tor ~/.local/lib/cwtch/cwtch