#!/usr/bin/env bash

set -euo pipefail

source scripts/subword_functions.sh

corpus_name=${corpus_name}
language=${language}
supp_dir=$(pwd)/supplemental_data
data_dir=${data_dir}
dest_dir=${dest_dir}
dest_path=${dest_dir}/${corpus_name}
subword_model_path=${subword_model_path:-""}
subword_vocab_size=${subword_vocab_size:-500} # nearly char level

# TODO: support existing subword model

mkdir -p $supp_dir $dest_dir

# if model path is empty, we train a new model for the corpus
# otherwise, we use the existing model
if [ -z "$subword_model_path" ]; then
    subword_model_path=${supp_dir}/${corpus_name}.spm.model
    train_sentencepiece_model \
        $data_dir/train.${language} \
        $supp_dir/${corpus_name}.spm \
        $subword_vocab_size
else
    echo "Using existing subword model: $subword_model_path"
fi

for split in train dev test; do
    apply_sentencepiece_model \
        ${subword_model_path} \
        $data_dir/${split}.${language} \
        $supp_dir/${corpus_name}.spm.${split}.${language}
done

fairseq-preprocess \
    --only-source \
    --workers 12  \
    --destdir ${dest_path} \
    --trainpref ${supp_dir}/${corpus_name}.spm.train.${language} \
    --validpref ${supp_dir}/${corpus_name}.spm.dev.${language} \
    --testpref ${supp_dir}/${corpus_name}.spm.test.${language}
