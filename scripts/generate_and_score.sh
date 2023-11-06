#!/usr/bin/env bash

set -euo pipefail

source ./scripts/subword_functions.sh

# user-specified args
src=${src_lang:-sme}
tgt=${tgt_lang:-fin}
beam_size=${beam_size:-1}
should_compute_metrics=${should_compute_metrics:-"no"}
raw_data_folder=${raw_data_folder:-"../raw_data"}
supplemental_data_folder=${supplemental_data_folder:-"../supplemental_data"}
binarized_data_folder=${binarized_data_folder:-"./binarized_data"}
checkpoint=${checkpoint:-"./checkpoint"}
max_tokens=${max_tokens:-17000}
buffer_size=${buffer_size:-1000}
split=${split:-"test"}
input_file=${input_data:-${supplemental_data_folder}/${split}.spm.${src}}
untouched_gold_file=${untouched_gold_file:-${raw_data_folder}/${split}.${tgt}}
eval_folder=${eval_folder}


# derived quantities
folder=${eval_folder}/beam${beam_size}
mkdir -p $folder
out=$folder/${split}.out
hyps=$folder/${split}.spm.hyps

# link spm input and untouched gold file into folder
ln -sf $(realpath ${input_file}) $folder/${split}.spm.${src}
ln -sf $(realpath ${untouched_gold_file}) $folder/${split}.${tgt}.detok

input_file=$folder/${split}.spm.${src}
untouched_gold_file=$folder/${split}.${tgt}.detok

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
    < "${input_file}" > "${out}"

cat "${out}" | grep '^H-' | sed "s/^H-//g" | sort -k1 -n | cut -f3 >"${hyps}"

# Detokenize fairseq output
hyps_orig=$hyps
hyps=${hyps}.detok
reverse_sentencepiece_segmentation $hyps_orig $hyps

if [ "${should_compute_metrics}" = "yes" ]
then
    for metric in bleu chrf
    do

        score=$folder/${split}.score_${metric}
        sacrebleu $untouched_gold_file \
            -i ${hyps} \
            -b \
            -m ${metric} \
            -w 4 > ${score}
    done
fi
