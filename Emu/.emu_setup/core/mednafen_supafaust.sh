#!/bin/sh

EMU_NAME="$(echo "$1" | cut -d'/' -f5)"
CONFIG="/mnt/SDCARD/Emu/${EMU_NAME}/config.json"
SYS_OPT="/mnt/SDCARD/Emu/.emu_setup/options/${EMU_NAME}.opt"

sed -i 's|"Emu Core: (✓CHIMERASNES)-supafaust-snes9x"|"Emu Core: chimerasnes-(✓SUPAFAUST)-snes9x"|g' "$CONFIG"
sed -i 's|"/mnt/SDCARD/Emu/.emu_setup/core/mednafen_supafaust.sh"|"/mnt/SDCARD/Emu/.emu_setup/core/snes9x.sh"|g' "$CONFIG"
sed -i 's|CORE=.*|CORE=\"mednafen_supafaust\"|g' "$SYS_OPT"