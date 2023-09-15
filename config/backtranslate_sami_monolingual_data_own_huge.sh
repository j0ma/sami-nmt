export randseg_random_seed=1234
export randseg_source_language=sme
export randseg_target_language=fin
export randseg_should_preprocess=yes
export randseg_should_evaluate=yes
export randseg_should_score=no
export randseg_use_sentencepiece=yes
export randseg_new_eval_name=bt_sme2fin_own_huge

export randseg_new_eval_raw_data_folder=${randseg_existing_train_folder}/raw_data/
export randseg_new_eval_raw_data_folder=${randseg_new_eval_raw_data_folder}/../mono_to_bt/
export randseg_new_eval_binarized_data_folder=./fin_sme_bin/bt_fin2sme_${randseg_new_eval_name}_$(date +%s)
mkdir -p $randseg_new_eval_binarized_data_folder

export randseg_max_tokens=100000
export randseg_should_score=no
