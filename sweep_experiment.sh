#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH --ntasks=1
#SBATCH --account=guest
#SBATCH --partition=guest-gpu
#SBATCH --qos=low-gpu
#SBATCH --export=ALL
#SBATCH --requeue
#SBATCH --gres=gpu:V100:8
#SBATCH --mail-user=jonnesaleva@brandeis.edu
#SBATCH --mail-type=FAIL,CANCEL
#SBATCH --output=%x-%j.out

env
locale

test -z "${randseg_cfg_file}" && exit 1
test -z "${randseg_hparams_folder}" && exit 1

run_single_exp () {
    local gpu_idx=$1
    shift
    local hparams=$1
    shift

    export randseg_random_seed=1234 # same for all fin-sme
    export randseg_temperature=1.0

    export randseg_num_merges=$(echo $hparams | cut -f1 -d' ')
    export randseg_train_data_type=$(echo $hparams | cut -f2 -d' ')
    export randseg_direction=$(echo $hparams | cut -f3 -d' ')

    case $randseg_train_data_type in
        baseline)
            if [ "${randseg_direction}" = "bidirectional" ]
            then
                export randseg_raw_data_folder=./data/fin-sme/bidirectional_baseline/
                export randseg_cfg_file=./config/bidirectional_baseline_cfg.sh
            else
                export randseg_raw_data_folder=./data/fin-sme/
                export randseg_cfg_file=${randseg_direction}_cfg.sh
            fi
            ;;
        bt_nmt_all)
            export randseg_raw_data_folder=./data/fin-sme/nmt_bt
            export randseg_cfg_file=./config/nmt_bt_${randseg_direction}_cfg.sh
            ;;
        bt_rbmt_all)
            export randseg_raw_data_folder=./data/fin-sme/rbmt_bt
            export randseg_cfg_file=./config/rbmt_bt_${randseg_direction}_cfg.sh
            ;;
        bt_nmt_clean)
            export randseg_cfg_file=./config/clean_nmt_bt_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/clean_nmt_bt
            ;;
        bt_rbmt_clean)
            export randseg_cfg_file=./config/clean_rbmt_bt_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/clean_rbmt_bt
            ;;
        bt_nmt_all_rbmt_all)
            export randseg_cfg_file=./config/rbmt_nmt_bt_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/rbmt_nmt_bt
            ;;
        bt_nmt_clean_rbmt_clean)
            export randseg_cfg_file=./config/clean_rbmt_nmt_bt_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/clean_rbmt_nmt_bt
            ;;
        bt_nmt_clean_rbmt_all)
            export randseg_cfg_file=./config/clean_nmt_all_rbmt_bt_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/clean_nmt_all_rbmt_bt
            ;;
        own_huge2)
            export randseg_cfg_file=./config/own_bt_huge2_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/own_bt_huge2_fin2sme
            ;;
        own_huge)
            if [ "${randseg_direction}" = "bidirectional" ]
            then
                export randseg_raw_data_folder=./data/fin-sme/bidirectional_own_bt_huge
                export randseg_cfg_file=./config/bidirectional_own_bt_huge_cfg.sh
            else
                export randseg_raw_data_folder=./data/fin-sme/own_bt_huge
                export randseg_cfg_file=./config/own_bt_huge_${randseg_direction}_cfg.sh
            fi
            ;;
        own)
            export randseg_cfg_file=./config/own_bt_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/own_bt_onceonly
            ;;
        own_beam1)
            export randseg_cfg_file=./config/own_bt_beam1_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/own_bt_beam1
            ;;
        own_beam1_huge)
            export randseg_cfg_file=./config/own_bt_beam1_huge_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/own_bt_beam1_plus_huge
            ;;
        *)
            exit
    esac

    CUDA_VISIBLE_DEVICES=${gpu_idx} ./full_experiment.sh "${randseg_cfg_file}" false false

}

export -f run_single_exp


gpus=$(echo $CUDA_VISIBLE_DEVICES | tr "," " ")
num_gpus=$(echo $CUDA_VISIBLE_DEVICES | tr "," "\n" | wc -l)
taskid=${SLURM_ARRAY_TASK_ID}

# Set env var `randseg_hparams_folder` to a folder
# where each SLURM worker can pick tasks from TSV
hparams_file=${randseg_hparams_folder}/worker${taskid}.tsv

echo "Number of GPUs: $num_gpus"

parallel --delay '5s' --jobs $num_gpus --link "run_single_exp {1} {2}" ::: ${gpus} :::: $hparams_file
