launch_exp() {
    long_lang=$1
    num_merges=$2

    export randseg_hparams_folder=$(realpath ./config/sweep_conditions_${num_merges}_1worker_1seed)
    export randseg_experiment_name=english2${long_lang}_countprop_${num_merges}_fixeduniform_real_1SEED_DEBUG_DELME
    export randseg_cfg_file=$(realpath ./config/english2${long_lang}_sweep_countprop_cfg.sh)
    #export randseg_should_preprocess=yes
    #export randseg_should_create_experiment=no
    #export randseg_should_train=yes
    export randseg_should_evaluate=yes

    sbatch -J ${num_merges}-${long_lang}-${bpe_type} --array=1 sweep_experiment.sh

}

export -f launch_exp

# create and start these
#parallel "randseg_should_train=yes randseg_should_preprocess=yes randseg_should_create_experiment=yes launch_exp {1} {2} {3}" ::: finnish estonian german uzbek ::: 2k 5k 32k

# quick test run
parallel "randseg_train_on_dev=yes randseg_should_train=yes randseg_should_preprocess=yes randseg_should_create_experiment=yes launch_exp {1} {2} {3}" ::: finnish ::: 2k 
