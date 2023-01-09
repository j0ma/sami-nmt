#!/usr/bin/env bash

set -euo pipefail

export data_folder=$1
export src_language=${2:-eng}
export tgt_language=${3:-uzb}

. scripts/seq_length_functions.sh

detailed_segmentation_tsv () {
    local txt_file=$1
    printf "%s\t%s\t%s\t%s\n" "sentence_idx" "num_words" "num_subwords" "num_chars"
    parallel --tagstr '{#}' "echo {1} | pee 'seq_len_words' 'seq_len_tokens' 'seq_len_chars' | tr '\n' '\t'; echo" :::: $txt_file | sort --numeric | sed "s/\t$//g"
}

summarized_segmentation_tsv () {
    local tsv_file=$1
    xsv stats --median -d'\t' "$tsv_file" | xsv 'select' "field,min,median,mean,max,stddev" | xsv fmt -t"\t"
}

vocab_with_rank () {
    local lang=$1
    cat -n $data_folder/bpe_vocab.$lang
}



main () {

    local data_folder=$1
    local lang=$2

    analyzed_folder=$data_folder/analyzed/
    mkdir -p $analyzed_folder

    text_file=$data_folder/dev.bpe.${lang}
    detailed=$analyzed_folder/detailed_bpe_compression_${lang}.tsv
    summarized=$analyzed_folder/summarized_bpe_compression_${lang}.tsv
    vocab_with_rank=$analyzed_folder/bpe_vocab_with_rank.${lang}
    sha_hash=$analyzed_folder/vocab_sha_hash.${lang}

    sha256sum ${text_file} > $sha_hash
    detailed_segmentation_tsv $text_file > $detailed
    summarized_segmentation_tsv $detailed > $summarized
    vocab_with_rank $lang > $vocab_with_rank

}

export -f detailed_segmentation_tsv
export -f summarized_segmentation_tsv
export -f vocab_with_rank
export -f main

parallel "main $data_folder {1}" ::: $src_language $tgt_language
