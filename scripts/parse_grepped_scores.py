import csv
import click

def parse_hyperparameters(file_path):


    hyperparams = {}
    # Split the file path into parts based on '/'
    parts = file_path.split('/')
    # Extract the hyperparameters from the relevant parts of the file path
    first_chunk = parts[2]
    second_chunk = parts[4]
    third_chunk = parts[5]

    hyperparams['language'] = first_chunk.split('_')[0].replace("english2", "")
    hyperparams['bpe_type'] = "countprop" if "countprop" in file_path else first_chunk.split('_')[1]
    hyperparams['num_merges'] = int(first_chunk.split('_')[3].replace('k', '000'))
    hyperparams['temperature'] = float(second_chunk.split('_')[-1].replace('temperature', ''))
    hyperparams['seed'] = int(second_chunk.split('_')[-2].replace("_", ""))
    hyperparams['split'] = third_chunk.split('.')[0]
    hyperparams['metric'] = third_chunk.split('_')[-1]

    return hyperparams


@click.command()
@click.option("--delimiter", default="\t", help="Delimiter character for input TSV")
def main(delimiter):

    input_columns = ["file_path", "value"]
    output_columns = [
        "language",
        "bpe_type",
        "num_merges",
        "temperature",
        "split",
        "seed",
        "metric",
        "value",
    ]

    # Open the input and output streams
    input_stream = click.get_text_stream("stdin")
    output_stream = click.get_text_stream("stdout")

    reader = csv.DictReader(input_stream, fieldnames=input_columns, delimiter=delimiter)
    writer = csv.DictWriter(
        output_stream, fieldnames=output_columns, delimiter=delimiter
    )

    # Write the header row for the output TSV
    # Loop over the input rows and parse the file path for each row
    writer.writeheader()
    for row in reader:
        file_path = row["file_path"]
        score = row["value"]
        hyperparams = parse_hyperparameters(file_path)
            
        # Write a row to the output TSV containing the parsed hyperparameters and the score
        writer.writerow(
            dict(
                zip(
                    output_columns,
                    [
                        hyperparams["language"],
                        hyperparams["bpe_type"],
                        hyperparams["num_merges"],
                        hyperparams["temperature"],
                        hyperparams["split"],
                        hyperparams["seed"],
                        hyperparams["metric"],
                        score,
                    ],
                )
            )
        )


if __name__ == "__main__":

    main()
