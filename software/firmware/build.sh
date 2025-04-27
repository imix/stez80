#!/usr/bin/bash
docker run  -v .:/src/ -it z88dk/z88dk z80asm -b monitor.asm
