#!/usr/bin/env bash

resolve_data_folder_and_cfg_file() {

    case $randseg_train_data_type in
        baseline)
            if [ "${randseg_direction}" = "bidirectional" ]
            then
                export randseg_raw_data_folder=./data/fin-sme/bidirectional_baseline/
                export randseg_cfg_file=./config/${randseg_direction}/bidirectional_baseline_cfg.sh
            else
                export randseg_raw_data_folder=./data/fin-sme/
                export randseg_cfg_file=${randseg_direction}_cfg.sh
            fi
            ;;
        bt_nmt_all)
            export randseg_raw_data_folder=./data/fin-sme/nmt_bt
            export randseg_cfg_file=./config/${randseg_direction}/nmt_bt_${randseg_direction}_cfg.sh
            ;;
        bt_rbmt_all)
            export randseg_raw_data_folder=./data/fin-sme/rbmt_bt
            export randseg_cfg_file=./config/${randseg_direction}/rbmt_bt_${randseg_direction}_cfg.sh
            ;;
        bt_nmt_clean)
            export randseg_cfg_file=./config/${randseg_direction}/clean_nmt_bt_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/clean_nmt_bt
            ;;
        bt_rbmt_clean)
            export randseg_cfg_file=./config/${randseg_direction}/clean_rbmt_bt_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/clean_rbmt_bt
            ;;
        bt_nmt_all_rbmt_all)
            export randseg_cfg_file=./config/${randseg_direction}/rbmt_nmt_bt_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/rbmt_nmt_bt
            ;;
        bt_nmt_clean_rbmt_clean)
            export randseg_cfg_file=./config/${randseg_direction}/clean_rbmt_nmt_bt_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/clean_rbmt_nmt_bt
            ;;
        bt_nmt_clean_rbmt_all)
            export randseg_cfg_file=./config/${randseg_direction}/clean_nmt_all_rbmt_bt_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/clean_nmt_all_rbmt_bt
            ;;
        own_huge2)
            export randseg_cfg_file=./config/${randseg_direction}/own_bt_huge2_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/own_bt_huge2_fin2sme
            ;;
        own_huge)
            if [ "${randseg_direction}" = "bidirectional" ]
            then
                export randseg_raw_data_folder=./data/fin-sme/bidirectional_own_bt_huge
                export randseg_cfg_file=./config/${randseg_direction}/bidirectional_own_bt_huge_cfg.sh
            elif [ "${randseg_joint_subwords}" = "yes" ]
            then
                export randseg_raw_data_folder=./data/fin-sme/own_bt_huge
                export randseg_cfg_file=./config/${randseg_direction}/joint_own_bt_huge_${randseg_direction}_cfg.sh
            elif [ "${character_level_model}" = "yes" ]
            then
                export randseg_raw_data_folder=./data/fin-sme/own_bt_huge
                export randseg_cfg_file=./config/${randseg_direction}/char_own_bt_huge_${randseg_direction}_cfg.sh
            else
                export randseg_raw_data_folder=./data/fin-sme/own_bt_huge
                export randseg_cfg_file=./config/${randseg_direction}/own_bt_huge_${randseg_direction}_cfg.sh
            fi
            ;;
        own)
            if [ "${randseg_joint_subwords}" = "yes" ]
            then
                export randseg_raw_data_folder=./data/fin-sme/own_bt_onceonly
                export randseg_cfg_file=./config/${randseg_direction}/joint_own_bt_${randseg_direction}_cfg.sh
            elif [ "${character_level_model}" = "yes" ]
            then
                export randseg_raw_data_folder=./data/fin-sme/own_bt_onceonly
                export randseg_cfg_file=./config/${randseg_direction}/char_own_bt_${randseg_direction}_cfg.sh
            else
                export randseg_cfg_file=./config/${randseg_direction}/own_bt_${randseg_direction}_cfg.sh
                export randseg_raw_data_folder=./data/fin-sme/own_bt_onceonly
            fi
            ;;
        own_beam1)
            export randseg_cfg_file=./config/${randseg_direction}/own_bt_beam1_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/own_bt_beam1
            ;;
        own_beam1_huge)
            export randseg_cfg_file=./config/${randseg_direction}/own_bt_beam1_huge_${randseg_direction}_cfg.sh
            export randseg_raw_data_folder=./data/fin-sme/own_bt_beam1_plus_huge
            ;;
        *)
            exit
    esac

}
