#!/usr/bin/env bash


preprocess_for_translation() {
    echo "❗ Preprocessing..."

    train_folder="${randseg_root_folder}/${randseg_experiment_name}/train/${randseg_model_name}"
    data_folder="${train_folder}/raw_data"
    binarized_data_folder="${train_folder}/binarized_data"
    supplemental_data_folder="${train_folder}/supplemental_data"

    env | rg '^randseg' | tee ${supplemental_data_folder}/relevant_environment_variables.txt

    src=${randseg_source_language}
    tgt=${randseg_target_language}

    # Train BPE/RandBPE using the train seg

    if [ "${character_level_model}" = "yes" ]
    then
        subword_suffix="char"
        for language in "${src}" "${tgt}"
        do
            for split in "train" "dev" "test"; do
                echo "[${language}, ${split}] Segmenting into characters..."
                text_file="${data_folder}/${split}.${language}"
                out_file=${supplemental_data_folder}/${split}.char.${language}
                apply_character_segmentation \
                    "${text_file}" \
                    "${out_file}"

                n_lines_in_out=$(wc -l ${out_file} | cut -f1 -d' ')
                echo "[${language}, ${split}] Number of lines in ${out_file}: ${n_lines_in_out}"
            done
        done
    elif [ "$randseg_use_sentencepiece" = "yes" ]
    then
        subword_suffix="spm"
        if [ "$randseg_joint_subwords" = "yes" ]
        then

            spm_model_vocab_prefix=${supplemental_data_folder}/joint.spm

            # combine the two languages 
            joint_data_file=${data_folder}/train.joint
            cat ${data_folder}/train.${src} ${data_folder}/train.${tgt} > ${joint_data_file}

            echo "[${language}] Learning JOINT SentencePiece ULM on train..."
            echo "[${language}] Note: Vocab size will be taken from 'randseg_num_merges' env var"
            train_sentencepiece_model \
                ${joint_data_file} \
                "${spm_model_vocab_prefix}" \
                "${randseg_num_merges}"

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
            echo "[${language}] Learning SentencePiece ULM on train..."
            echo "[${language}] Note: Vocab size will be taken from 'randseg_num_merges' env var"
            train_sentencepiece_model \
                "${data_folder}/train.${language}" \
                "${spm_model_vocab_prefix}" \
                "${randseg_num_merges}"

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
    else
        subword_suffix="bpe"
        if [ "$randseg_joint_subwords" = "yes" ]
        then
            # combine the two languages 
            joint_data_file=${data_folder}/train.joint
            cat ${data_folder}/train.${src} ${data_folder}/train.${tgt} > ${joint_data_file}

            codes=${supplemental_data_folder}/joint.bpe.codes
            echo "[joint] Learning JOINT BPE on train..."

            learn_bpe \
                ${joint_data_file} \
                "${randseg_num_merges}" \
                "${codes}" \
                "${randseg_pick_randomly}" \
                "${randseg_uniform}" \
                "${randseg_temperature}" \
                "${randseg_random_seed}" \
                "${randseg_count_proportional}"

            for language in "${src}" "${tgt}"
            do
                for split in "train" "dev" "test"; do
                    echo "[${language}, ${split}] Segmenting with BPE..."
                    text_file="${data_folder}/${split}.${language}"
                    out_file=${supplemental_data_folder}/${split}.bpe.${language}
                    apply_bpe \
                        "${text_file}" \
                        "${codes}" \
                        "${out_file}"
                done
                vocab_file=${supplemental_data_folder}/bpe_vocab.${language}
                train_bpe_segmented="${supplemental_data_folder}/train.bpe.${language}"
                get_vocab "${train_bpe_segmented}" "${vocab_file}"
            done
        else
            codes=${supplemental_data_folder}/${language}.bpe.codes
            echo "[${language}] Learning BPE on train..."
            learn_bpe \
                "${data_folder}/train.${language}" \
                "${randseg_num_merges}" \
                "${codes}" \
                "${randseg_pick_randomly}" \
                "${randseg_uniform}" \
                "${randseg_temperature}" \
                "${randseg_random_seed}" \
                "${randseg_count_proportional}"

            for split in "train" "dev" "test"; do
                echo "[${language}, ${split}] Segmenting with BPE..."
                text_file="${data_folder}/${split}.${language}"
                out_file=${supplemental_data_folder}/${split}.bpe.${language}
                apply_bpe \
                    "${text_file}" \
                    "${codes}" \
                    "${out_file}"
            done
            vocab_file=${supplemental_data_folder}/bpe_vocab.${language}
            train_bpe_segmented="${supplemental_data_folder}/train.bpe.${language}"
            get_vocab "${train_bpe_segmented}" "${vocab_file}"
        fi
    fi

    if [ "${randseg_train_on_dev}" = "yes" ]
    then
        trainpref="${supplemental_data_folder}/dev.${subword_suffix}"
    else
        trainpref="${supplemental_data_folder}/train.${subword_suffix}"
    fi

    if [ "${randseg_tie_all_embeddings}" = "yes" ]; then
        joined_dictionary_flag="--joined-dictionary"
    else
        joined_dictionary_flag=""
    fi
    echo "joined_dictionary_flag=${joined_dictionary_flag}"


    fairseq-preprocess \
        --source-lang "${src}" --target-lang "${tgt}" \
        --trainpref "${trainpref}" \
        --validpref "${supplemental_data_folder}/dev.${subword_suffix}" \
        --testpref "${supplemental_data_folder}/test.${subword_suffix}" \
        --destdir "${randseg_binarized_data_folder}" \
        --workers "${randseg_num_parallel_workers}" \
        ${joined_dictionary_flag}

    echo "✅ Done!"

}
