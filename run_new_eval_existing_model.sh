#!/usr/bin/env bash

# Complete experiment sequence
set -eo pipefail

echo "Execution environment:"
env

source scripts/subword_functions.sh

# Constants
config_file=$1
cuda_visible=${CUDA_VISIBLE_DEVICES:-""}

check_these_vars=(
    "randseg_random_seed"
    "randseg_source_language"
    "randseg_target_language"
	"randseg_should_preprocess"
	"randseg_should_evaluate"
	"randseg_should_score"
    "randseg_use_sentencepiece"
    "randseg_max_tokens"
    "randseg_new_eval_name"
    "randseg_new_eval_raw_data_folder"
    "randseg_new_eval_binarized_data_folder"
    "randseg_existing_train_folder"
)

activate_conda_env () {
    source /home/$(whoami)/miniconda3/etc/profile.d/conda.sh
    conda activate randseg
}

check_deps() {
    echo "❗  Checking dependencies..."
    while read -r dep; do
        test -z "$(which $dep)" &&
            echo "Missing dependency: ${dep}" &&
            exit 1 || echo "Found ${dep} ➡  $(which $dep)"
    done <requirements_external.txt
    echo "✅  Dependencies seem OK"
}

fill_optionals() {
    source config/default_hparams.sh
}

check_env() {
    echo "❗ Checking environment..."

    # First fill optionals with defaults
    fill_optionals

    # Then source the config
    source "${config}" || exit

    # Then check mandatory variables
    missing=false
    for var in "${check_these_vars[@]}"; do
        eval "test -z \$$var" &&
            echo "Missing variable: $var" &&
            missing="true"
    done
    test "$missing" = "true" && exit 1

    echo "✅  Environment seems OK"
}

create_eval_folder() {
    echo "❗ Creating  eval folder"

    local new_eval_name=${randseg_new_eval_name}
    local raw_data_folder=${randseg_new_eval_raw_data_folder}
    local binarized_data_folder=${randseg_new_eval_binarized_data_folder}
    local train_folder=${randseg_existing_train_folder}

    local experiments_folder=$(realpath ${train_folder}/../../../)
    local experiment_name=$(basename $(realpath ${train_folder}/../../))

    prepx create \
        --eval-only \
        --eval-name ${new_eval_name} \
        --raw-data-folder ${raw_data_folder} \
        --binarized-data-folder ${binarized_data_folder} \
        --eval-checkpoint ${train_folder}/checkpoints/checkpoint_best.pt \
        --root-folder ${experiments_folder} \
        --experiment-name ${experiment_name} || echo "Failed to create eval! Maybe it exists already?"
}


preprocess() {
    echo "❗ Preprocessing..."

    local new_eval_name=${randseg_new_eval_name}
    local train_folder=${randseg_existing_train_folder}
    local supplemental_data_folder=${train_folder}/supplemental_data

    local experiment_folder=$(realpath ${train_folder}/../../../)
    local experiment_name=$(basename $(realpath ${train_folder}/../../))
    local new_eval_folder="${experiment_folder}/${experiment_name}/eval/${new_eval_name}"

    env | rg '^randseg' | tee ${new_eval_folder}/relevant_environment_variables.txt

    src=${randseg_source_language}
    tgt=${randseg_target_language}

    # Train BPE/RandBPE using the train seg
    for language in "${src}" "${tgt}"; do

        if [ "$randseg_use_sentencepiece" = "yes" ]
        then
            subword_suffix="spm"
            spm_model_vocab_prefix=${supplemental_data_folder}/${language}.spm
            spm_model_file=${spm_model_vocab_prefix}.model
            spm_vocab_file=${spm_model_vocab_prefix}.vocab
            echo "[${language}, test] Segmenting with SentencePiece ULM..."
            text_file="${new_eval_folder}/raw_data/test.${language}"
            out_file=${new_eval_folder}/test.spm.${language}
            apply_sentencepiece_model \
                "${spm_model_file}" \
                "${text_file}" \
                "${out_file}"
        else
            subword_suffix="bpe"
            codes=${supplemental_data_folder}/${language}.bpe.codes
            echo "[${language}, test] Segmenting with BPE..."
            text_file="${new_eval_folder}/raw_data/test.${language}"
            out_file=${new_eval_folder}/test.bpe.${language}
            apply_bpe \
                "${text_file}" \
                "${codes}" \
                "${out_file}"
        fi
    done

    if [ "${randseg_tie_all_embeddings}" = "yes" ]; then
        joined_dictionary_flag="--joined-dictionary"
    else
        joined_dictionary_flag=""
    fi
    echo "joined_dictionary_flag=${joined_dictionary_flag}"
  
    new_binarized_data_folder="${new_eval_folder}/binarized_data"
    fairseq-preprocess \
        --source-lang "${src}" --target-lang "${tgt}" \
        --srcdict ${train_folder}/binarized_data/dict.${src}.txt \
        --testpref "${new_eval_folder}/test.${subword_suffix}" \
        --destdir ${new_binarized_data_folder} \
        --workers "${randseg_num_parallel_workers}" \
        ${joined_dictionary_flag}

    echo "✅ Done!"

}


reverse_subword_segmentation () {
    local input_file=$1
    local output_file=$2

    if [ "$randseg_use_sentencepiece" = "yes" ]
    then
        reverse_sentencepiece_segmentation \
            "${input_file}" \
            "${output_file}"
    else
        reverse_bpe_segmentation \
            "${input_file}" \
            "${output_file}"
    fi

}

generate_and_score() {

    # Fairseq insists on calling the dev-set "valid"; hack around this.
    local split="${1/dev/valid}"

    local new_eval_name=${randseg_new_eval_name}
    local train_folder=${randseg_existing_train_folder}
    local supplemental_data_folder=${train_folder}/supplemental_data

    local experiment_folder=$(realpath ${train_folder}/../../../)
    local experiment_name=$(basename $(realpath ${train_folder}/../../))
    local new_eval_folder="${experiment_folder}/${experiment_name}/eval/${new_eval_name}"

    # Notes
    # - binarized_data_folder: contains .bin, .idx files as well as dict .txt files
    #   - should have been created by call to preprocess
    # - data_folder: contains the raw text data
    local data_folder="${new_eval_folder}/raw_data"
    local binarized_data_folder="${new_eval_folder}/binarized_data"
    #local data_folder="${randseg_new_eval_raw_data_folder:-$_raw_data_folder}"
    #local binarized_data_folder="${randseg_new_eval_binarized_data_folder:-$_binarized_data_folder}"
 
    local src=${randseg_source_language}
    local tgt=${randseg_target_language}

    echo "❗ [${split}] Evaluating..."

    local checkpoint_file="${new_eval_folder}/checkpoint"
    local out="${new_eval_folder}/${split}.out"
    local source_tsv="${new_eval_folder}/${split}_with_source.tsv"
    local gold="${new_eval_folder}/${split}.gold"
    local hyps="${new_eval_folder}/${split}.hyps"
    local source="${new_eval_folder}/${split}.source"
    local score="${new_eval_folder}/${split}.eval.score"
    local score_tsv="${new_eval_folder}/${split}_eval_results.tsv"

    # Make raw predictions
    fairseq-generate \
        "${binarized_data_folder}" \
        --source-lang="${src}" \
        --target-lang="${tgt}" \
        --path="${checkpoint_file}" \
        --seed="${randseg_random_seed}" \
        --gen-subset="${split}" \
        --beam="${randseg_beam_size}" \
        --max-tokens=${randseg_max_tokens} \
        --no-progress-bar | tee "${out}"

    # Also separate gold/system output/source into separate text files
    # (Sort by index to ensure output is in the same order as plain text data)
    cat "${out}" | grep '^T-' | sed "s/^T-//g" | sort -k1 -n | cut -f2 >"${gold}"
    cat "${out}" | grep '^H-' | sed "s/^H-//g" | sort -k1 -n | cut -f3 >"${hyps}"
    cat "${out}" | grep '^S-' | sed "s/^S-//g" | sort -k1 -n | cut -f2 >"${source}"

    # Detokenize fairseq output
    source_orig=$source
    source=${source}.detok
    reverse_subword_segmentation $source_orig $source

    gold_orig=$gold
    gold=${gold}.detok
    reverse_subword_segmentation $gold_orig $gold

    hyps_orig=$hyps
    hyps=${hyps}.detok
    reverse_subword_segmentation $hyps_orig $hyps

    paste "${gold}" "${hyps}" "${source}" >"${source_tsv}"

    if [[ "$randseg_should_score" = "yes" ]]; then
        # Compute some evaluation metrics
        python scripts/evaluate.py \
            --references-path "${gold}" \
            --hypotheses-path "${hyps}" \
            --source-path "${source}" \
            --score-output-path "${score}" \
            --output-as-tsv

        cat "${score}"
    fi

    echo "✅ Done!"

}

main() {
    local config=$1

    activate_conda_env

    # These should always happen
    check_deps
    check_env

    # always create eval
    create_eval_folder

    # preprocess if necessary
    if [[ "$randseg_should_preprocess" = "yes" ]]; then
        preprocess
    else
        echo not preprocessing
    fi

    if [[ "$randseg_should_evaluate" = "yes" ]]; then
        generate_and_score "test" # split always test


        if [[ "$randseg_should_score" = "yes" ]]; then
            experiment_folder=$(realpath ${randseg_existing_train_folder}/../../)
            bash scripts/rescore_experiment.sh ${experiment_folder}
        fi
    else
        echo not evaluating
    fi

}

main "${config_file}" 
