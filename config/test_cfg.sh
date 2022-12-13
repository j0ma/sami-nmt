#!/usr/bin/env bash

export randseg_checkpoints_folder=/data/randseg_ckpt_test
export randseg_experiment_name=TEST_talitiainen
export randseg_model_name=valiaikainen
export randseg_random_seed=2022
export randseg_pick_randomly=yes
export randseg_num_merges=5000
export randseg_root_folder=./experiments
export randseg_raw_data_folder=./data/est-eng
export randseg_binarized_data_folder=/tmp/randseg_bindata_test
export randseg_source_language=eng
export randseg_target_language=est

mkdir -p $randseg_checkpoints_folder $randseg_binarized_data_folder
