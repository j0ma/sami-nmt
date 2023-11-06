#!/usr/bin/env bash

create_yle_eval_folder() {
    echo "❗ Creating  eval folder"

    local new_eval_name="eval_yle_${randseg_model_name}"
    local raw_data_folder=${yle_raw_data_folder}
    local evals_root_folder=./experiments/${randseg_experiment_name}/eval/
    local train_folder=./experiments/${randseg_experiment_name}/train/${randseg_model_name}
    local binarized_data_folder=/dev/null # yle will be evaluated using fairseq-interactive

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

    # link new eval_folder to old train folder as "eval_yle"
    local eval_folder=${evals_root_folder}/${new_eval_name}
    local create_link_here=${train_folder}/eval_yle

    echo "❗ Creating link at ${create_link_here}"
    ln -sf ${eval_folder} ${create_link_here}

}

preprocess_yle() {
    local train_folder=./experiments/${randseg_experiment_name}/train/${randseg_model_name}
    local eval_folder="${randseg_root_folder}/${randseg_experiment_name}/eval/eval_yle_${randseg_model_name}"
    local data_folder="${eval_folder}/raw_data"
    local binarized_data_folder="${eval_folder}/binarized_data"
    local supplemental_data_folder="${train_folder}/supplemental_data"
    local supplemental_data_folder_eval="${eval_folder}/supplemental_data"

    mkdir -p ${supplemental_data_folder_eval}

    src=${randseg_source_language}
    tgt=${randseg_target_language}

    echo "❗ Preprocessing YLE..."
    # Train BPE/RandBPE using the train seg
    subword_suffix="spm"
    if [ "$randseg_joint_subwords" = "yes" ]
    then

        spm_model_vocab_prefix=${supplemental_data_folder}/joint.${subword_suffix}
        spm_model_file=$spm_model_vocab_prefix.model
        spm_vocab_file=$spm_model_vocab_prefix.vocab

        for language in "${src}" "${tgt}"
        do
            echo "[${language}, test] Segmenting with SentencePiece ULM..."
            text_file="${data_folder}/test.${language}"
            out_file=${supplemental_data_folder_eval}/test.spm.${language}
            apply_sentencepiece_model \
                "${spm_model_file}" \
                "${text_file}" \
                "${out_file}"

            n_lines_in_out=$(wc -l ${out_file} | cut -f1 -d' ')
            echo "[${language}, test] Number of lines in ${out_file}: ${n_lines_in_out}"
        done
    else
        for language in "${src}" "${tgt}"
        do
            spm_model_vocab_prefix=${supplemental_data_folder}/${language}.spm
            spm_model_file=$spm_model_vocab_prefix.model
            spm_vocab_file=$spm_model_vocab_prefix.vocab

            echo "[${language}, test] Segmenting with SentencePiece ULM..."
            text_file="${data_folder}/test.${language}"
            out_file=${supplemental_data_folder_eval}/test.spm.${language}
            apply_sentencepiece_model \
                "${spm_model_file}" \
                "${text_file}" \
                "${out_file}"

            n_lines_in_out=$(wc -l ${out_file} | cut -f1 -d' ')
            echo "[${language}, test] Number of lines in spm output file: ${n_lines_in_out}"
        done
    fi
}

evaluate_yle() {

    # Fairseq insists on calling the dev-set "valid"; hack around this.
    local split="${1/dev/valid}"

    experiment_folder="${randseg_root_folder}/${randseg_experiment_name}"
    train_folder="${randseg_root_folder}/${randseg_experiment_name}/train/${randseg_model_name}"
    eval_folder="${randseg_root_folder}/${randseg_experiment_name}/eval/eval_yle_${randseg_model_name}"
    data_folder="${eval_folder}/raw_data"
    supplemental_data_folder="${eval_folder}/supplemental_data"
    binarized_data_folder="${train_folder}/binarized_data"

    src=${randseg_source_language}
    tgt=${randseg_target_language}

    echo "❗ [${split}] Evaluating YLE..."

    checkpoint_file="${eval_folder}/checkpoint"
    untouched_detok_ref="${eval_folder}/raw_data/${split}.detok.${tgt}"

    out="${eval_folder}/${split}.out"
    source_tsv="${eval_folder}/${split}_with_source.tsv"
    gold_file="${eval_folder}/${split}.gold"
    hyps_file="${eval_folder}/${split}.hyps"
    source_file="${eval_folder}/${split}.source"

    
    # call generate_and_score.sh
    src_lang=${src} \
    tgt_lang=${tgt} \
    checkpoint=${checkpoint_file} \
    beam_size=${randseg_beam_size} \
    should_compute_metrics=yes \
    supplemental_data_folder=${supplemental_data_folder} \
    binarized_data_folder=${binarized_data_folder} \
    max_tokens=${randseg_max_tokens} \
    buffer_size=1000 \
    split=${split} \
    input_file=${supplemental_data_folder}/yle/${split}.spm.${src} \
    eval_folder=${eval_folder} \
    raw_data_folder=${data_folder} \
    ./scripts/generate_and_score.sh


    echo "✅ Done!"

}

run_yle_eval() {
    echo "❗ Running YLE..."
    create_yle_eval_folder
    preprocess_yle
    evaluate_yle "test"
}
