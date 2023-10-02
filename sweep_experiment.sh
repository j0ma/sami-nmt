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

test -z "${randseg_hparams_folder}" && exit 1

parse_json_hparams() {
    local hparams=$1
    for key in $(echo $hparams | jq -r 'keys[]'); do
        export $key=$(echo $hparams | jq -r --arg k "$key" '.[$k]')
    done
}

sort_out_hyperparams() {
    local hparams_line=$1
    parse_json_hparams "${hparams_line}"
    data_and_cfg_json=$(
        python scripts/resolve_data_folder_and_cfg_file.py \
            --direction "${randseg_direction}" \
            --train-data-type "${randseg_train_data_type}"
    )

    export randseg_data_folder=$(echo ${data_and_cfg_json} | jq -r '.data_folder')
    export randseg_cfg_file=$(echo ${data_and_cfg_json} | jq -r '.cfg_file')
}

run_single_exp () {
    local gpu_idx=$1
    shift
    local hparams=$1
    shift

    export randseg_joint_subwords=yes
    sort_out_hyperparams "$hparams"

    env | rg '^randseg_'

    CUDA_VISIBLE_DEVICES=${gpu_idx} ./full_experiment.sh "${randseg_cfg_file}" false

}

export -f run_single_exp
export -f sort_out_hyperparams
export -f parse_json_hparams

gpus=$(echo ${CUDA_VISIBLE_DEVICES:-""} | tr "," " ")
num_gpus=$(echo ${CUDA_VISIBLE_DEVICES:-""} | tr "," "\n" | wc -l)
taskid=${SLURM_ARRAY_TASK_ID:-1}

# Set env var `randseg_hparams_folder` to a folder
# where each SLURM worker can pick tasks from TSV
hparams_file=${randseg_hparams_folder}/worker${taskid}.jsonl

echo "Number of GPUs: $num_gpus"

parallel --jobs $num_gpus --link 'run_single_exp {1} {2}' ::: ${} :::: ${hparams_file}
