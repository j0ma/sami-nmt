#!/usr/bin/env bash

set -euxo pipefail

source ~/sami-nmt/scripts/subword_functions.sh

# user-specified args
src=${src_lang:-sme}
tgt=${tgt_lang:-fin}
beam_size=${beam_size:-1}
should_compute_metrics=${should_compute_metrics:-"no"}
binarized_data_folder=${binarized_data_folder:-"./binarized_data"}
checkpoint=${checkpoint:-"./checkpoint"}
max_tokens=${max_tokens:-17000}
buffer_size=${buffer_size:-1000}
split=${split:-"test"}

# derived quantities
folder=beam${beam_size}
mkdir -p $folder
out=$folder/${split}.out
hyps=$folder/${split}.spm.hyps

gpus=${CUDA_VISIBLE_DEVICES:-""}

if [ -z "${gpus}" ]
then
    echo "Using CPU"
    cpu_flag="--cpu"
else
    echo "Using GPU"
    cpu_flag=""
fi

fairseq-interactive \
    ${binarized_data_folder} \
    ${cpu_flag} \
    --source-lang="${src}" \
    --target-lang="${tgt}" \
    --path=${checkpoint} \
    --seed=1234 \
    --gen-subset="${split}" \
    --beam="${beam_size}" \
    --max-tokens ${max_tokens} \
    --buffer-size ${buffer_size} \
    --no-progress-bar < ${split}.spm.${src} | tee "${out}"


cat "${out}" | grep '^H-' | sed "s/^H-//g" | sort -k1 -n | cut -f3 >"${hyps}"

# Detokenize fairseq output
hyps_orig=$hyps
hyps=${hyps}.detok
reverse_sentencepiece_segmentation $hyps_orig $hyps

if [ "${should_compute_metrics}" = "yes" ]
then
    for metric in bleu chrf
    do

        if [ -f "${split}.${tgt}" ]
        then
            gold_file=${split}.${tgt}
        else
            gold_file=${split}.gold.detok
        fi
        score=$folder/${split}.score_${metric}
        sacrebleu $gold_file \
            -i ${hyps} \
            -b \
            -m ${metric} \
            -w 4 > ${score}
    done
fi
