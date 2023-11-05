#!/usr/bin/env bash

train() {
    echo "❗ Starting training..."

    train_folder="${randseg_root_folder}/${randseg_experiment_name}/train/${randseg_model_name}"
    data_folder="${train_folder}/raw_data"
    binarized_data_folder="${train_folder}/binarized_data"
    checkpoints_folder="${train_folder}/checkpoints"
    supplemental_data_folder="${train_folder}/supplemental_data"
    tensorboard_folder="${train_folder}/tensorboard"
    train_log_file="${train_folder}/train.log"
    cpu_gpu_fp16_flag=$(test -z "${cuda_visible}" && echo "--cpu" || echo "--fp16")

    if [ -z "${cuda_visible}" ]
    then
        echo "❗ [train] WARNING: CUDA_VISIBLE_DEVICES is not set. Running in CPU mode."
        sleep 2
    fi

    if [ "${randseg_use_sentencepiece}" = "yes" ]
    then
        remove_bpe_flag="sentencepiece"
    else
        remove_bpe_flag="subword_nmt"
    fi

    src=${randseg_source_language}
    tgt=${randseg_target_language}

    warmup_updates_flag="--warmup-updates=${randseg_warmup_updates}"

    if [[ "${randseg_lr_scheduler}" == "inverse_sqrt" ]]; then
        warmup_init_lr_flag="--warmup-init-lr=${randseg_warmup_init_lr}"
    else
        warmup_init_lr_flag=""
    fi

    if [ "${randseg_tie_all_embeddings}" = "yes" ]; then
        tie_embeddings_flag="--share-all-embeddings"
    else
        tie_embeddings_flag="--share-decoder-input-output-embed"
    fi
    echo "tie_embeddings_flag=${tie_embeddings_flag}"

    if [ "${randseg_encoder_normalize_before}" = "yes" ]; then
        encoder_normalize_before_flag="--encoder-normalize-before"
    else
        encoder_normalize_before_flag=""
    fi

    if [ "${randseg_decoder_normalize_before}" = "yes" ]; then
        decoder_normalize_before_flag="--decoder-normalize-before"
    else
        decoder_normalize_before_flag=""
    fi



    fairseq-train \
        "${binarized_data_folder}" \
        ${cpu_gpu_fp16_flag} ${warmup_updates_flag} ${warmup_init_lr_flag} \
        ${tie_embeddings_flag} \
        ${encoder_normalize_before_flag} \
        ${decoder_normalize_before_flag} \
        --save-dir="${checkpoints_folder}" \
        --tensorboard-logdir="${tensorboard_folder}" \
        --source-lang="${src}" \
        --target-lang="${tgt}" \
        --log-format="json" \
        --seed="${randseg_random_seed}" \
        --patience=${randseg_patience} \
        --arch=transformer \
        --attention-dropout="${randseg_p_dropout}" \
        --activation-dropout="${randseg_p_dropout}" \
        --activation-fn="${randseg_activation_fn}" \
        --encoder-embed-dim="${randseg_encoder_embedding_dim}" \
        --encoder-ffn-embed-dim="${randseg_encoder_hidden_size}" \
        --encoder-layers="${randseg_encoder_layers}" \
        --encoder-attention-heads="${randseg_encoder_attention_heads}" \
        --decoder-embed-dim="${randseg_decoder_embedding_dim}" \
        --decoder-ffn-embed-dim="${randseg_decoder_hidden_size}" \
        --decoder-layers="${randseg_decoder_layers}" \
        --decoder-attention-heads="${randseg_decoder_attention_heads}" \
        --criterion="${randseg_criterion}" \
        --label-smoothing="${randseg_label_smoothing}" \
        --optimizer="${randseg_optimizer}" \
        --lr="${randseg_lr}" \
        --lr-scheduler="${randseg_lr_scheduler}" \
        --clip-norm="${randseg_clip_norm}" \
        --max-tokens="${randseg_max_tokens}" \
        --max-update="${randseg_max_update}" \
        --save-interval="${randseg_save_interval}" \
        --validate-interval-updates="${randseg_validate_interval_updates}" \
        --adam-betas '(0.9, 0.98)' --update-freq="${randseg_update_freq}" \
        --user-dir "./fairseq_extension/user" \
        --no-epoch-checkpoints \
        --max-source-positions 1400 \
        --max-target-positions 1400 \
        --eval-bleu \
        --eval-bleu-remove-bpe ${remove_bpe_flag} \
        --eval-bleu-detok "moses" \
        --skip-invalid-size-inputs-valid-test |
        tee "${train_log_file}"

    echo "✅ Done training..."
    echo "✅ Done!"
}
