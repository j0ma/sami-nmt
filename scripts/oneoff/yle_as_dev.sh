#!/usr/bin/env bash

set -euxo pipefail

yle_path=$(realpath ./data/fin-sme/yle/)

for folder in bidirectional_baseline bidirectional_own_bt_huge clean_nmt_all_rbmt_bt clean_nmt_bt clean_rbmt_bt clean_rbmt_nmt_bt mono_to_bt mono_to_bt_wikipedia_filtered mono_to_bt_wikipedia_unfiltered nmt_bt own_bt own_bt_beam1 own_bt_beam1_plus_huge own_bt_huge own_bt_huge2_fin2sme own_bt_OLD own_bt_onceonly rbmt_bt rbmt_nmt_bt
do
    abs_path=$(realpath ./data/fin-sme/$folder/)
    rm $abs_path/dev.*
    ln -sf $yle_path/test.fin $abs_path/dev.fin
    ln -sf $yle_path/test.sme $abs_path/dev.sme
done
