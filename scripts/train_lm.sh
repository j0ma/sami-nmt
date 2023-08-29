#!/usr/bin/env bash

set -euo pipefail

bin_data_folder=${bin_data_folder}
config_file=${config_file}
checkpoint_save_dir=${checkpoint_save_dir}
use_cpu=${use_cpu:-"yes"}

cpu_flag=$([ "$use_cpu" == "yes" ] && echo "--cpu" || echo "")
fairseq_lm_command_stub="fairseq-train ${cpu_flag} --save-dir ${checkpoint_save_dir} --task language_modeling"
fairseq_lm_command=$(./scripts/create_command "$fairseq_lm_command_stub" "${config_file}")

eval "$fairseq_lm_command ${bin_data_folder}"
