#!/usr/bin/env bash

# Downloads data for English - <lang> using MTData
# Note: meant to be run from the base dir of the repo 

set -euo pipefail

mtdata_download () {

    local -r corpus_name="$1"
    shift
    local -r src_lang="$1"
    shift
    local -r tgt_lang="$1"
    shift
    local -r destination="$1"
    shift

    # go to directory with recipes
    pushd config

    # actually perform download
    mtdata get-recipe \
        -ri "${corpus_name}-${src_lang}-${tgt_lang}" \
        -o "${destination}"
    
    # go back
    popd
}

src_lang=${src_lang}
tgt_lang=${tgt_lang}
data_folder=${data_folder:-./data}
corpus_name=${corpus_name:-hansard}

destination="${data_folder}/${src_lang}-${tgt_lang}/${corpus_name}/download"

mkdir -vp $destination

mtdata_download $corpus_name $src_lang $tgt_lang $destination
