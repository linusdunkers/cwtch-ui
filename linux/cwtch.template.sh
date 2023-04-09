#!/bin/sh

exec env LD_LIBRARY_PATH=PREFIX/lib/cwtch/:PREFIX/lib/cwtch/Tor PREFIX/lib/cwtch/cwtch
