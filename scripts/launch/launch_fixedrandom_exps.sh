launch_exp() {
    long_lang=$1
    bpe_type=$2
    num_merges=$3

    export randseg_hparams_folder=$(realpath ./config/sweep_conditions_${num_merges}_1worker)
    export randseg_experiment_name=english2${long_lang}_${bpe_type}bpe_${num_merges}_fixedrandom_lastmin
    export randseg_cfg_file=$(realpath ./config/english2${long_lang}_sweep_${bpe_type}bpe_cfg.sh)
    #export randseg_should_preprocess=yes
    #export randseg_should_create_experiment=no
    export randseg_should_train=yes
    export randseg_should_evaluate=yes

    sbatch -J ${num_merges}-${long_lang}-${bpe_type} --array=1 sweep_experiment.sh

}

export -f launch_exp

# start these
#parallel "randseg_should_preprocess=yes randseg_should_create_experiment=yes launch_exp {1} {2} {3}" ::: finnish estonian ::: rand ::: 2k
#parallel "randseg_should_preprocess=yes randseg_should_create_experiment=yes launch_exp {1} {2} {3}" ::: german uzbek ::: rand ::: 2k 5k 32k

# continue these
#parallel "randseg_should_preprocess=no randseg_should_create_experiment=no launch_exp {1} {2} {3}" ::: finnish estonian ::: rand ::: 5k 32k

parallel "randseg_should_preprocess=yes randseg_should_create_experiment=yes launch_exp {1} {2} {3}" ::: german ::: rand ::: 2k 5k 32k
