launch_exp() {
    long_lang=$1
    bpe_type=$2
    num_merges=$3

    export randseg_hparams_folder=$(realpath ./config/sweep_conditions_${num_merges}_1worker)
    export randseg_experiment_name=english2${long_lang}_${bpe_type}bpe_${num_merges}_fixeduniform_real
    export randseg_cfg_file=$(realpath ./config/english2${long_lang}_sweep_${bpe_type}bpe_cfg.sh)
    #export randseg_should_preprocess=yes
    #export randseg_should_create_experiment=no
    #export randseg_should_train=yes
    export randseg_should_evaluate=yes

    sbatch -J ${num_merges}-${long_lang}-${bpe_type} --array=1 sweep_experiment.sh

}

export -f launch_exp

# create and start these
#parallel "randseg_should_train=yes randseg_should_preprocess=yes randseg_should_create_experiment=yes launch_exp {1} {2} {3}" ::: finnish estonian german uzbek ::: uniform_rand ::: 2k 5k 32k

# continue ones already there
#parallel "randseg_should_train=yes randseg_should_preprocess=no randseg_should_create_experiment=no launch_exp {1} {2} {3}" ::: german estonian ::: uniform_rand ::: 5k
#parallel "randseg_should_train=yes randseg_should_preprocess=yes randseg_should_create_experiment=yes launch_exp {1} {2} {3}" ::: german ::: uniform_rand ::: 32k

# eval this
parallel "randseg_should_preprocess=no randseg_should_create_experiment=no randseg_should_train=no launch_exp {1} {2} {3}" ::: uzbek ::: uniform_rand ::: 5k
