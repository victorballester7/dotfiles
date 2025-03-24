#!/bin/bash

usage() {
    echo "Usage: $0 -c file1 file2 ... output_archive"
    echo "       $0 -x archive destination_directory"
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
        if [[ $# -ne 2 ]]; then
            usage
        fi
        archive="$1"
        destination="$2"

        mkdir -p "$destination"

        case "$archive" in
            *.zip)
                unzip "$archive" -d "$destination"
                ;;
            *.rar)
                unrar x "$archive" "$destination/"
                ;;
            *.tar)
                tar -xf "$archive" -C "$destination"
                ;;
            *.tar.gz)
                tar -xzf "$archive" -C "$destination"
                ;;
            *.tar.bz2)
                tar -xjf "$archive" -C "$destination"
                ;;
            *.tar.xz)
                tar -xJf "$archive" -C "$destination"
                ;;
            *)
                echo "Unsupported archive format"
                exit 1
                ;;
        esac
        ;;
    
    *)
        usage
        ;;
esac
