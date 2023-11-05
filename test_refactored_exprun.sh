#!/usr/bin/env bash

set -euox pipefail

source ./scripts/experiment_functions/create_experiment.sh

export randseg_experiment_name=TEST_fin2sme_refactored_exprun
export randseg_hparams_folder=/home/jonne/research/fcf-northern-sami/sami-nmt/config/fin2sme/optim_dropout_hidden_sweep

json_hparams=$(head -n1 $randseg_hparams_folder/worker1.jsonl)
sort_out_hyperparams "$json_hparams"
env | rg '^randseg_'

bash ./full_experiment.sh \
    $randseg_cfg_file yes
