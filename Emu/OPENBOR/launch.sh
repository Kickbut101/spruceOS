#!/bin/sh

HOME=`dirname "$0"`
mypak=`basename "$1"`
OVR_DIR="$HOME/overrides"
OVERRIDE="$OVR_DIR/$mypak.opt"

. "$HOME/default.opt"
. "$HOME/system.opt"
if [ -f "$OVERRIDE" ]; then
	. "$OVERRIDE";
fi

/mnt/SDCARD/App/utils/utils $GOV $CORES $CPU $GPU $DDR $SWAP

export LD_LIBRARY_PATH=lib:/usr/miyoo/lib:/usr/lib

cd $HOME
if [ "$mypak" == "Final Fight LNS.pak" ]; then
    ./OpenBOR_mod "$1"
else
    ./OpenBOR_new "$1"
fi
sync