#!/usr/bin/env bash

learn_bpe() {
    local text_file=$1
    local num_operations=$2
    local codes_file=$3
    local pick_randomly=$4
    local uniform=$5
    local temperature=$6
    local random_bpe_seed=$7
    local count_proportional=$8

    pick_randomly_flag=""
   
    if [ "${pick_randomly}" = "yes" ]; then
        pick_randomly_flag="${pick_randomly_flag} --pick-randomly"

        if [ "${uniform}" = "yes" ] 
        then
            pick_randomly_flag="${pick_randomly_flag} --uniform"
        elif [ "${count_proportional}" = "yes" ]
        then
            pick_randomly_flag="${pick_randomly_flag} --count-proportional"
        fi

        if [ -n "${temperature}" ] 
        then
            pick_randomly_flag="${pick_randomly_flag} --temperature ${temperature}"
        fi
        if [ -n "${random_bpe_seed}" ] 
        then
            pick_randomly_flag="${pick_randomly_flag} --random-seed-for-merges ${random_bpe_seed}"
        fi
    fi

    subword-nmt learn-bpe \
        $pick_randomly_flag \
        -s "${num_operations}" \
        <"${text_file}" \
        >"${codes_file}"
}

apply_bpe() {
    local text_file=$1
    local codes_file=$2
    local out_file=$3

  echo "[apply_bpe] BPE codes file: ${codes_file}"
  echo "[apply_bpe] Input file: ${text_file}"
  echo "[apply_bpe] Output file: ${out_file}"

    subword-nmt apply-bpe \
        -c "${codes_file}" \
        <"${text_file}" \
        >"${out_file}"
}

get_vocab() {
    local text_file=$1
    local vocab_file=$2
    subword-nmt get-vocab \
        -i "${text_file}" \
        -o "${vocab_file}"
}

reverse_bpe_segmentation() {
    local text_file=$1
    local out_file=$2
    sed -r 's/(@@ )|(@@ ?$)//g' <"${text_file}" | sacremoses detokenize >"${out_file}"
}


# Function to train SentencePiece model
train_sentencepiece_model() {
  input_file=$1
  model_prefix=$2
  vocab_size=$3

  # Check if all arguments are provided
  if [ -z "$input_file" ] || [ -z "$model_prefix" ] || [ -z "$vocab_size" ]; then
    echo "Usage: train_sentencepiece_model <input_file> <model_prefix> <vocab_size>"
    return 1
  fi

  # Train SentencePiece model
  echo "spm_train binary: $(which spm_train)"
  spm_train \
	 --input=$input_file \
	 --model_prefix=$model_prefix \
	 --vocab_size=$vocab_size \
	 --character_coverage 1
}

# Function to apply SentencePiece model
apply_sentencepiece_model() {
  model_file=$1
  input_file=$2
  output_file=$3

  echo "[apply_sentencepiece_model] Model file: ${model_file}"
  echo "[apply_sentencepiece_model] Input file: ${input_file}"
  echo "[apply_sentencepiece_model] Output file: ${output_file}"

  # Check if all arguments are provided
  if [ -z "$model_file" ] || [ -z "$input_file" ]; then
    echo "Usage: apply_sentencepiece_model <model_file> <input_file>"
    return 1
  fi

  # Apply SentencePiece model
  echo "spm_encode binary: $(which spm_encode)"
  spm_encode \
	 --model=$model_file \
	 --output_format=piece \
     --input $input_file \
     --output $output_file
}

# Function to get SentencePiece subword vocabulary
get_sentencepiece_subword_vocabulary() {
  model_file=$1
  output_file=$2

  # Check if model file is provided
  if [ -z "$model_file" ]; then
    echo "Usage: get_sentencepiece_subword_vocabulary <model_file>"
    return 1
  fi

  # Get SentencePiece subword vocabulary
  spm_export_vocab --model=$model_file --output_format=vocab > $output_file
}

reverse_sentencepiece_segmentation() {
    local text_file=$1
    local out_file=$2
    sed -r \
        -e 's/ //g' \
        -e 's/▁/ /g' \
        <"${text_file}" \
    | sacremoses detokenize >"${out_file}"
}

# Export functions
export -f learn_bpe
export -f apply_bpe
export -f get_vocab
export -f reverse_bpe_segmentation
export -f train_sentencepiece_model
export -f apply_sentencepiece_model
export -f get_sentencepiece_subword_vocabulary
