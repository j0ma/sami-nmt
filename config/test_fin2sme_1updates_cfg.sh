#!/usr/bin/env bash

export randseg_pick_randomly=no
export randseg_uniform=no
export randseg_root_folder=./experiments
export randseg_raw_data_folder=./data/fin-sme
export randseg_source_language=fin
export randseg_target_language=sme
export randseg_checkpoints_folder=./fin_sme_bin/TEST_sloth_likes_to_eat_bananas_$(date +%s)
export randseg_binarized_data_folder=./fin_sme_bin/TEST_sloth_likes_to_eat_bananas_$(date +%s)
export randseg_model_name=baseline

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder

export randseg_max_tokens="500" 
export randseg_max_update="1"

#export randseg_patience="10" 

export randseg_joint_subwords=yes
export randseg_experiment_name=TEST_sloth_likes_to_eat_bananas
export randseg_random_seed=1234
export randseg_num_merges=500
export randseg_should_create_experiment=yes
export randseg_should_preprocess=yes
export randseg_should_train=yes
export randseg_should_evaluate=yes
export randseg_use_sentencepiece=no
