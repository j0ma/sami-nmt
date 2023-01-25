#!/usr/bin/env bash
#

process_line () {
    local line=$1
    local mops=$(echo $line | cut -f1 -d' ')
    local seed=$(echo $line | cut -f2 -d' ')
    local temperature=$(echo $line | cut -f3 -d' ')
    local fpath=$(echo $line | cut -f4 -d' ')
    local output_folder=vocab_analyses/${mops}/${temperature}/${seed}/
    mkdir -p $output_folder
    mv -v $fpath $output_folder/
}

export -f process_line

cat - | parallel --bar --progress "process_line {1}"
