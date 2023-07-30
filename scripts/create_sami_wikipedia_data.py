import datasets as ds
import pandas as pd
import click
from tqdm import tqdm


@click.command()
@click.option("--slug", default="20230601.se")
def main(slug):

    # load huggingface wikipedia dataset in sami
    sami_wikipedia = ds.load_dataset("graelo/wikipedia", slug)["train"]["text"]

    with click.get_text_stream("stdout") as stdout, click.get_text_stream(
        "stderr"
    ) as stderr:
        for line in tqdm(sami_wikipedia, file=stderr):
            click.echo(line, file=stdout)


if __name__ == "__main__":
    main()
