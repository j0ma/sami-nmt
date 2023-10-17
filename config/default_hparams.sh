#!/usr/bin/env bash

set_env_var() {
    if [ -z "${!1}" ]; then
        echo "Setting variable $1=$2"
        export $1=$2
    fi
}

set_env_var randseg_num_merges 8000
set_env_var randseg_activation_fn "relu"
set_env_var randseg_max_tokens "12000"
set_env_var randseg_beam_size 6
set_env_var randseg_clip_norm "1"
set_env_var randseg_criterion "label_smoothed_cross_entropy"
set_env_var randseg_decoder_attention_heads "2"
set_env_var randseg_decoder_embedding_dim "512"
set_env_var randseg_decoder_hidden_size "512"
set_env_var randseg_decoder_layers "6"
set_env_var randseg_encoder_attention_heads "2"
set_env_var randseg_encoder_embedding_dim "512"
set_env_var randseg_encoder_hidden_size "512"
set_env_var randseg_encoder_layers "6"
set_env_var randseg_eval_mode "dev"
set_env_var randseg_eval_name "transformer"
set_env_var randseg_label_smoothing "0.1"
set_env_var randseg_langs_file ""
set_env_var randseg_lr "0.0005"
set_env_var randseg_lr_scheduler "inverse_sqrt"
set_env_var randseg_max_update "15000"
set_env_var randseg_num_parallel_workers 16
set_env_var randseg_optimizer "adam"
set_env_var randseg_patience -1 
set_env_var randseg_p_dropout "0.3"
set_env_var randseg_save_interval "5"
set_env_var randseg_validate_interval "1"
set_env_var randseg_validate_interval_updates "5000"
set_env_var randseg_warmup_init_lr "0.0003"
set_env_var randseg_warmup_updates "2000"
set_env_var randseg_update_freq 20
set_env_var randseg_uniform "no"
set_env_var randseg_train_on_dev "no"
set_env_var randseg_tie_all_embeddings "yes"
set_env_var randseg_encoder_normalize_before "no"
set_env_var randseg_decoder_normalize_before "no"
set_env_var randseg_use_sentencepiece "yes"
set_env_var randseg_should_score "yes"
set_env_var randseg_joint_subwords "no"
set_env_var character_level_model "no"
set_env_var randseg_random_seed 1234
set_env_var randseg_temperature 1.0
set_env_var randseg_eval_yle "yes"
