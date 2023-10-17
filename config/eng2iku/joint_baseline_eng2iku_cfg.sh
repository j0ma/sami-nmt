#!/usr/bin/env bash

export randseg_pick_randomly=no
export randseg_uniform=no
export randseg_root_folder=./experiments
#export randseg_raw_data_folder=./data/eng-iku/hansard/
export randseg_source_language=eng
export randseg_target_language=iku
export randseg_checkpoints_folder=./eng_iku_bin/eng_iku_${randseg_train_data_type}_checkpoints_$(date +%s)
export randseg_binarized_data_folder=./eng_iku_bin/eng_iku_${randseg_train_data_type}_binarized_data_$(date +%s)
export randseg_model_name=${randseg_train_data_type}_${randseg_encoder_hidden_size}hidden_${randseg_encoder_attention_heads}heads_${randseg_num_merges}merges_${randseg_p_dropout}dropout_${randseg_encoder_embedding_dim}encoderemb_${randseg_decoder_embedding_dim}decoderemb

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder

export randseg_max_tokens="20000" 
#export randseg_max_update=15000
export randseg_joint_subwords=yes
export randseg_lr=0.001
