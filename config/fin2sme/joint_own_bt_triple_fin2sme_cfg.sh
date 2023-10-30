#!/usr/bin/env bash

export randseg_pick_randomly=no
export randseg_uniform=no
export randseg_root_folder=./experiments
export randseg_source_language=fin
export randseg_target_language=sme
export randseg_checkpoints_folder=./fin_sme_bin/own_bt_triple_checkpoints_$(date +%s)
export randseg_binarized_data_folder=./fin_sme_bin/own_bt_triple_bindata_$(date +%s)
export randseg_model_name=${randseg_train_data_type}_${randseg_encoder_hidden_size}hidden_${randseg_encoder_attention_heads}heads_${randseg_num_merges}merges_${randseg_p_dropout}dropout_${randseg_encoder_embedding_dim}encembsize_${randseg_decoder_embedding_dim}decembsize

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder

export randseg_max_tokens="17000" 
#export randseg_max_update=15000
export randseg_joint_subwords=yes
export randseg_lr=0.0005

