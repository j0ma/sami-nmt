#!/usr/bin/env bash

move_to_scratch () {
    fpath=$1
    dest_folder=~/scratch0/randbpe-bin/eng-fin-bin
    dest=${dest_folder}/$(basename $fpath)
    mv -v $fpath $dest
    ln -vs $dest $fpath
}

export -f move_to_scratch

cat -  | parallel --bar --progress "move_to_scratch {1}"

