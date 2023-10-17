#!/usr/bin/env bash

evaluate() {

    # Fairseq insists on calling the dev-set "valid"; hack around this.
    local split="${1/dev/valid}"

    experiment_folder="${randseg_root_folder}/${randseg_experiment_name}"
    train_folder="${randseg_root_folder}/${randseg_experiment_name}/train/${randseg_model_name}"
    eval_folder="${randseg_root_folder}/${randseg_experiment_name}/train/${randseg_model_name}/eval"
    data_folder="${eval_folder}/raw_data"
    binarized_data_folder="${train_folder}/binarized_data"
    checkpoints_folder="${train_folder}/checkpoints"
    supplemental_data_folder="${train_folder}/supplemental_data"
    train_log_file="${train_folder}/train.log"
    cpu_gpu_fp16_flag=$(test -z "${cuda_visible}" && echo "--cpu" || echo "--fp16")

    if [ "${randseg_use_sentencepiece}" = "yes" ]
    then
        remove_bpe_flag="sentencepiece"
    else
        remove_bpe_flag="subword_nmt"
    fi

    src=${randseg_source_language}
    tgt=${randseg_target_language}

    echo "❗ [${split}] Evaluating..."

    if [[ -z $randseg_beam_size ]]; then
        readonly randseg_beam_size=5
    fi

    CHECKPOINT_FILE="${eval_folder}/checkpoint"
    UNTOUCHED_DETOK_REF="${eval_folder}/raw_data/${split}.detok.${tgt}"

    OUT="${eval_folder}/${split}.out"
    SOURCE_TSV="${eval_folder}/${split}_with_source.tsv"
    GOLD="${eval_folder}/${split}.gold"
    HYPS="${eval_folder}/${split}.hyps"
    SOURCE="${eval_folder}/${split}.source"

    # Make raw predictions
    fairseq-generate \
        "${binarized_data_folder}" \
        --source-lang="${src}" \
        --target-lang="${tgt}" \
        --path="${CHECKPOINT_FILE}" \
        --seed="${randseg_random_seed}" \
        --gen-subset="${split}" \
        --beam="${randseg_beam_size}" \
        --task translation \
        --max-source-positions 1400 \
        --max-target-positions 1400 \
        --no-progress-bar | tee "${OUT}"

        #--remove-bpe ${remove_bpe_flag} \
        #--max-source-positions=2500 --max-target-positions=2500 \

    # Also separate gold/system output/source into separate text files
    # (Sort by index to ensure output is in the same order as plain text data)
    cat "${OUT}" | grep '^T-' | sed "s/^T-//g" | sort -k1 -n | cut -f2 >"${GOLD}"
    cat "${OUT}" | grep '^H-' | sed "s/^H-//g" | sort -k1 -n | cut -f3 >"${HYPS}"
    cat "${OUT}" | grep '^S-' | sed "s/^S-//g" | sort -k1 -n | cut -f2 >"${SOURCE}"

    # Detokenize fairseq output
    SOURCE_ORIG=$SOURCE
    SOURCE=${SOURCE}.detok
    reverse_subword_segmentation $SOURCE_ORIG $SOURCE

    GOLD_ORIG=$GOLD
    GOLD=${GOLD}.detok
    reverse_subword_segmentation $GOLD_ORIG $GOLD

    HYPS_ORIG=$HYPS
    HYPS=${HYPS}.detok
    reverse_subword_segmentation $HYPS_ORIG $HYPS

    paste "${GOLD}" "${HYPS}" "${SOURCE}" >"${SOURCE_TSV}"

    for metric in bleu chrf
    do
        sacrebleu_out_file="${split}.eval.score_sacrebleu_${metric}"
        sacrebleu ${split}.gold${detok_suffix} \
            -i ${split}.hyps${detok_suffix} \
            -b -m ${metric} -w 4 \
            > "${sacrebleu_out_file}"
    done

    echo "✅ Done!"

}
