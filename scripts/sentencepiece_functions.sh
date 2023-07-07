#!/bin/bash

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
  spm_train
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

  # Check if all arguments are provided
  if [ -z "$model_file" ] || [ -z "$input_file" ]; then
    echo "Usage: apply_sentencepiece_model <model_file> <input_file>"
    return 1
  fi

  # Apply SentencePiece model
  spm_encode
	 --model=$model_file \
	 --output_format=piece \
     < $input_file \
     > $output_file
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

# Export functions
export -f train_sentencepiece_model
export -f apply_sentencepiece_model
export -f get_sentencepiece_subword_vocabulary
