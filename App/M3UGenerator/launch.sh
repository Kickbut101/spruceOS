#!/bin/sh

ROMS_DIR="/mnt/SDCARD/Roms"
DISC_SYSTEMS="PS SEGACD NEOCD PCECD DC"
DISC_EXTS="cue|gdi|chd|pbp|iso|dsk"

generate_cues() {
    cd "$ROMS_DIR"
    find $DISC_SYSTEMS -maxdepth 3 -type f -name "*.bin" | while read -r target; do
        dirname="$(dirname "$target")"
        basename="$(basename "$target")"
        cuename="${basename%.*}"
        cuepath="$dirname/$cuename.cue"

        if echo "$cuename" | grep -q ' (Track [0-9][0-9]*)$' || [ -f "$cuepath" ]; then
            continue
        fi 

        echo "FILE \"$basename\" BINARY
  TRACK 01 MODE1/2352
    INDEX 01 00:00:00" > "$cuepath"
    done

    find $DISC_SYSTEMS -maxdepth 1 -type f -name "*_cache6.db" -exec rm -f {} +
}

generate_cues # generate any missing cue sheets

for system in $DISC_SYSTEMS; do
    FULLPATH="$ROMS_DIR/$system"

    if [ -d "$FULLPATH" ]; then
        cd "$FULLPATH"

        # Redump/No-Intro (revisionless)
        find . -maxdepth 1 ! -iname '*.m3u' -type f -iname "*([Dd][Ii][Ss][KkCc] 1).*[$DISC_EXTS]" | while read -r line; do
            FILENAME="$(echo "${line%.*}" | sed 's@./@@g' | sed 's@ ([Dd][Ii][Ss][KkCc] 1)@@g')"
            DIRNAME=".${FILENAME%"${FILENAME##*[![:space:]]}"}" # remove spaces at the end
            SEARCH_NAME="$(echo "${line%.*}" | sed 's@./@@g' | sed 's@([Dd][Ii][Ss][KkCc] 1)@([Dd][Ii][Ss][KkCc] ?)@g')"

            sync
            mkdir -p "$DIRNAME"

            find . -maxdepth 1 ! -iname '*.m3u' -type f -iname "$SEARCH_NAME.*" -exec mv -n -- '{}' "$DIRNAME" \; # move discs to directory
            find "$DIRNAME" ! -iname '*.m3u' -type f -iname "$SEARCH_NAME*.*[$DISC_EXTS]" | sed -e 's/^//' | sort > "$FILENAME.m3u"  # create playlist of discs
        done

        # Redump/No-Intro (with revisions)
        find . -maxdepth 1 ! -iname '*.m3u' -type f -iname "*([Dd][Ii][Ss][KkCc] 1) *.*[$DISC_EXTS]" | while read -r line; do
            FILENAME="$(echo "${line%.*}" | sed 's@./@@g' | sed 's@ ([Dd][Ii][Ss][KkCc] 1)@@g')"
            DIRNAME=".${FILENAME%"${FILENAME##*[![:space:]]}"}" # remove spaces at the end
            SEARCH_NAME="$(echo "${FILENAME}" | sed 's@([Dd][Ii][Ss][KkCc] 1)@([Dd][Ii][Ss][KkCc] ?)@g')"

            sync
            mkdir -p "$DIRNAME"

            find . -maxdepth 1 ! -iname '*.m3u' -type f -iname "$SEARCH_NAME.*" -exec mv -n -- '{}' "$DIRNAME" \; # move discs to directory
            find "$DIRNAME" ! -iname '*.m3u' -type f -iname "$SEARCH_NAME*.*[$DISC_EXTS]" | sort > "$FILENAME.m3u" # create playlist of discs
        done

        # TOSEC
        find . -maxdepth 1 ! -iname '*.m3u' -type f -iname "*([Dd][Ii][Ss][KkCc] 1 of ?).*[$DISC_EXTS]" | while read -r line; do
            FILENAME="$(echo "${line%.*}" | sed 's@./@@g' | sed 's@([Dd][Ii][Ss][KkCc] 1 of .*)@@g')"
            DIRNAME=".${FILENAME%"${FILENAME##*[![:space:]]}"}" # remove spaces at the end
            SEARCH_NAME="$(echo "${line%.*}" | sed 's@./@@g' | sed 's@([Dd][Ii][Ss][KkCc] 1 of@([Dd][Ii][Ss][KkCc] ? of@g')"

            sync
            mkdir -p "$DIRNAME"

            find . -maxdepth 1 ! -iname '*.m3u' -type f -iname "$SEARCH_NAME*.*" -exec mv -n -- '{}' "$DIRNAME" \; # move discs to directory
            find "$DIRNAME" ! -iname '*.m3u' -type f -iname "$SEARCH_NAME*.*[$DISC_EXTS]" | sort > "$FILENAME.m3u" # create playlist of discs
        done
    else
        echo "Directory $FULLPATH does not exist."
    fi
done

cd "$ROMS_DIR"
find $DISC_SYSTEMS -maxdepth 1 -type f -name "*_cache6.db" -exec rm -f {} +
sync