#!/usr/bin/env bash

set -euo pipefail

source scripts/subword_functions.sh

experiment_dir=${experiment_dir}
language=${language}
corpus_name=${corpus_name:-$language}
data_dir=${experiment_dir}/raw_data/
supp_dir=${experiment_dir}/supplemental_data/
dest_dir=${experiment_dir}/binarized_data/
subword_model_path=${subword_model_path:-""}
subword_vocab_size=${subword_vocab_size:-500} # nearly char level

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
    --destdir ${dest_dir} \
    --trainpref ${supp_dir}/${corpus_name}.spm.train.${language} \
    --validpref ${supp_dir}/${corpus_name}.spm.dev.${language} \
    --testpref ${supp_dir}/${corpus_name}.spm.test.${language}
