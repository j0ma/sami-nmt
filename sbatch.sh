srun -A guest -p guest-gpu --gres gpu:V100:1 --mem 64G --cpus-per-task 32 --ntasks 1 --qos low-gpu ./full_experiment.sh ./config/test_cfg.sh false false
