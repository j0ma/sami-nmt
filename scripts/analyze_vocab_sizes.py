import json
import click


def get_vocab(file_path):
    vocab = set()
    with open(file_path, "r") as f:
        for line in f:
            tokens = line.strip().split()
            for token in tokens:
                vocab.add(token.strip())
    return vocab


@click.command()
@click.option("--original-file", type=click.Path(exists=True))
@click.option("--subword-segmented-file", type=click.Path(exists=True))
def main(original_file, subword_segmented_file):

    original_vocab = get_vocab(original_file)
    subword_segmented_vocab = get_vocab(subword_segmented_file)

    original_vocab_size = len(original_vocab)
    subword_segmented_vocab_size = len(subword_segmented_vocab)

    output = {
        "original_vocab_size": original_vocab_size,
        "subword_segmented_vocab_size": subword_segmented_vocab_size,
    }

    click.echo(json.dumps(output, indent=4))


if __name__ == "__main__":
    main()
