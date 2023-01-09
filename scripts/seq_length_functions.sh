#!/usr/bin/env bash

seq_len_chars () {
    sed \
        -e "s/\(\s\|\t\)*//g" \
        -e "s/./ &/g" \
        -e "s/\(^\s\|\s$\)//g" \
        -e "s/\s/\n/g" \
        | tr " " "\n" \
        | wc -l
}

seq_len_tokens () {
    sed "s/\s/\n/g" | tr " " "\n" | wc -l
}

seq_len_words () {
    sed -r 's/(@@ )|(@@ ?$)//g' | seq_len_tokens
}

export -f seq_len_chars
export -f seq_len_tokens
export -f seq_len_words
