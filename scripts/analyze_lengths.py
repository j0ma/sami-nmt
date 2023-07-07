import sys
import statistics
import pandas as pd

# Parse command-line arguments to get list of input file names
input_files = sys.argv[1:]

# Create an empty dictionary to hold the for each input file
num_tokens = {input_file: [] for input_file in input_files}

# Read lines from input files and compute the of space-separated tokens on each line
for input_file in input_files:
    with open(input_file, "r") as f:
        for line in f:
            line = line.strip()  # remove trailing newline
            tokens = line.split()  # split line into tokens
            num_tokens[input_file].append(
                len(tokens)
            )  # add of tokens to list for input file

# Compute mean, median, and standard deviation of for each input file
results = []
for input_file in input_files:
    try:
        mean = statistics.mean(num_tokens[input_file])
        median = statistics.median(num_tokens[input_file])
        std_dev = statistics.stdev(num_tokens[input_file])
    except statistics.StatisticsError:
        print(f"Skipping: {input_file}", file=sys.stderr)
        continue

    results.append([input_file, "Mean", mean])
    results.append([input_file, "Median", median])
    results.append([input_file, "Standard deviation", std_dev])

# Format the results as a table
headers = ["Input file", "Statistic", "Value"]
results.sort(key=lambda x: x[0])  # sort results by second column, then by first column

results = (
    pd.DataFrame(results, columns=["filename", "statistic", "value"])
    .set_index(["filename", "statistic"])
    .unstack()
    .droplevel(axis=1, level=0)
    .reset_index()
)

rename_dict = {old: new for old, new in zip(["filename", "statistic", "value"], headers)}
results = results.rename(columns=rename_dict).set_index("Input file")

table = results.to_markdown(index=True)

# Print the table
print(table)
