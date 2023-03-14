import click
import json
from pathlib import Path

@click.command()
@click.argument("input_file", type=click.File(mode='r', encoding='utf-8'))
def main(input_file):

    with input_file:
        n_sentences = 0
        n_tokens = 0
        vocab = set()
        for row in input_file:
            n_sentences += 1
            tokens = row.split(" ")
            n_tokens += len(tokens)
            vocab.update(tokens)

        n_types = len(vocab)

        output = {
            "n_sentences": n_sentences,
            "n_tokens": n_tokens,
            "n_types": n_types,
            "input_file": Path(input_file)
        }
        json_str = json.dumps(output)
        click.echo(json_str, nl=True)
    

if __name__ == "__main__":
    main()
