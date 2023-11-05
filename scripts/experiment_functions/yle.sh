#!/usr/bin/env bash

preprocess_yle() {
    train_folder="${randseg_root_folder}/${randseg_experiment_name}/train/${randseg_model_name}"
    data_folder="${train_folder}/raw_data"
    binarized_data_folder="${train_folder}/binarized_data"
    supplemental_data_folder="${train_folder}/supplemental_data"

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
            for split in "train" "dev" "test"; do
                echo "[${language}, ${split}] Segmenting with SentencePiece ULM..."
                text_file="${data_folder}/${split}.${language}"
                out_file=${supplemental_data_folder}/${split}.spm.${language}
                apply_sentencepiece_model \
                    "${spm_model_file}" \
                    "${text_file}" \
                    "${out_file}"

                n_lines_in_out=$(wc -l ${out_file} | cut -f1 -d' ')
                echo "[${language}, ${split}] Number of lines in ${out_file}: ${n_lines_in_out}"
            done
        done
    else
        spm_model_vocab_prefix=${supplemental_data_folder}/${language}.spm
        spm_model_file=$spm_model_vocab_prefix.model
        spm_vocab_file=$spm_model_vocab_prefix.vocab

        for split in "train" "dev" "test"; do
            echo "[${language}, ${split}] Segmenting with SentencePiece ULM..."
            text_file="${data_folder}/${split}.${language}"
            out_file=${supplemental_data_folder}/${split}.spm.${language}
            apply_sentencepiece_model \
                "${spm_model_file}" \
                "${text_file}" \
                "${out_file}"

            n_lines_in_out=$(wc -l ${out_file} | cut -f1 -d' ')
            echo "[${language}, ${split}] Number of lines in spm output file: ${n_lines_in_out}"
        done
    fi
}

run_yle_eval() {
    echo "❗ Running YLE..."
    evaluate_yle "test"
}
