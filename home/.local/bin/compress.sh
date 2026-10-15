#!/bin/bash

usage() {
    echo "Usage: $0 -c file1 file2 ... output_archive"
    echo "       $0 -x archive1 archive2 ... destination_directory"
    exit 1
}

if [[ $# -lt 2 ]]; then
    usage
fi

mode="$1"
shift

case "$mode" in
    -c)
        if [[ $# -lt 2 ]]; then
            usage
        fi
        output_file="${@: -1}"
        files=("${@:1:$#-1}")

        case "$output_file" in
            *.zip)
                zip -r "$output_file" "${files[@]}"
                ;;
            *.rar)
                rar a "$output_file" "${files[@]}"
                ;;
            *.tar)
                tar -cf "$output_file" "${files[@]}"
                ;;
            *.tar.gz)
                tar -czf "$output_file" "${files[@]}"
                ;;
            *.tar.bz2)
                tar -cjf "$output_file" "${files[@]}"
                ;;
            *.tar.xz)
                tar -cJf "$output_file" "${files[@]}"
                ;;
            *)
                tar -cf "$output_file.tar" "${files[@]}"
                ;;
        esac
        ;;
    
    -x)
        archives=("${@:1:$#-1}")
        destination="${@: -1}"

        mkdir -p "$destination"

        # 7z handles every format and draws a progress bar (-bsp).
        # Compressed tarballs are decompressed by 7z and streamed into tar
        # in a single pass, so the progress bar covers the whole extraction.
        extract() {
            local archive="$1"
            echo "Extracting $(basename "$archive") -> $destination"
            case "${archive,,}" in
                *.tar.gz|*.tgz|*.tar.bz2|*.tbz|*.tbz2|*.tar.xz|*.txz|*.tar.zst|*.tzst)
                    7z x -so -bsp2 "$archive" | tar -xf - -C "$destination"
                    return $(( PIPESTATUS[0] || PIPESTATUS[1] ))
                    ;;
                *.zip|*.rar|*.7z|*.tar|*.gz|*.bz2|*.xz|*.zst|*.iso|*.cab)
                    7z x -bso0 -bsp1 -o"$destination" "$archive"
                    ;;
                *)
                    echo "Unsupported archive format"
                    return 1
                    ;;
            esac
        }

        status=0
        declare -A seen
        for archive in "${archives[@]}"; do
            # Multi-volume rar: any part extracts the whole set from part1,
            # and selecting several parts extracts the set only once.
            if [[ "$archive" =~ ^(.*\.part)0*[0-9]+\.rar$ ]]; then
                for first in "${BASH_REMATCH[1]}"{1,01,001}.rar; do
                    [[ -f "$first" ]] && { archive="$first"; break; }
                done
            fi
            [[ -n "${seen[$archive]}" ]] && continue
            seen[$archive]=1
            extract "$archive" || status=$?
        done

        # When run from a terminal (e.g. yazi's `shell --block`), keep the
        # error on screen instead of returning straight to the file manager.
        if (( status != 0 )) && [[ -t 0 ]]; then
            echo
            read -rsn1 -p "Extraction failed (exit $status). Press any key..."
        fi
        exit "$status"
        ;;
    
    *)
        usage
        ;;
esac
