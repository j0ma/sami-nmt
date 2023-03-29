from collections import defaultdict
from pathlib import Path
import pandas as pd
import sys

# Parse command-line arguments to get list of input file names
input_files = sys.argv[1:]

# Create an empty dictionary to hold the for each input file
num_tokens = defaultdict(list)

# Read lines from input files and compute the of space-separated tokens on each line
for input_file in input_files:
    _input_file  = Path(input_file)
    with open(input_file, 'r') as f:
        for line in f:
            line = line.strip() # remove trailing newline
            tokens = line.split() # split line into tokens
            num_tokens[_input_file.name].append(len(tokens)) # add of tokens to list for input file

# Create a DataFrame with the data
data = pd.DataFrame(num_tokens)

# Compute the statistics
stats = data.describe()

# Format the results as a table
table = stats.to_markdown()

# Print the table
print(table)
