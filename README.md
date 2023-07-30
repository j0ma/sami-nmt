# Sami NMT

## how to backtranslate

1. Generate Sami wikipedia plaintext by running `scripts/create_sami_wikipedia_data.py` and place it in `data/wikipedia`
2. Navigate to `data/wikipedia` and run `opusfilter scripts/opus_filters/clean_sami_wikipedia.yaml`
3. Navigate to `data/mono_to_bt_wikipedia_filtered` and run `opusfilter scripts/opus_filters/concatenate_sami_wikipedia_with_own_huge_bt_filtered.yaml`
4. Navigate to `data/mono_to_bt_wikipedia_unfiltered` and run `opusfilter scripts/opus_filters/concatenate_sami_wikipedia_with_own_huge_bt_unfiltered.yaml`
