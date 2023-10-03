import click
import json
from pathlib import Path
import functools as ft

import sacremoses as sm

import pandas as pd

UTF8 = "utf-8"
ENCODING = UTF8


def split_on_whitespace(s: str) -> list[str]:
    return s.split()


def tokenize_with_sacremoses(s: str, tokenizer) -> list[str]:
    return tokenizer.tokenize(s)


def get_inflected_words_from_text(file_obj, tokenize) -> set[str]:
    inflected_words = set()

    for line in file_obj:
        line = line.strip()

        if not line:
            continue
        inflected_words.update(tokenize(line))

    return inflected_words


@click.command()
@click.option(
    "--language", required=True, help="The language of the words in the text file."
)
@click.option(
    "--unimorph-file",
    required=True,
    type=click.Path(exists=True),
    help="Path to the Unimorph file.",
)
@click.option("--mode", type=click.Choice(["wordlist", "text"]), default="wordlist")
@click.option("--use-moses-tokenizer", is_flag=True)
@click.option("--moses-language", default="en")
@click.option("--include-covered-msd", is_flag=True)
@click.argument("input-file", type=click.File("r", encoding=ENCODING), default="-")
def check_coverage(
    language,
    unimorph_file,
    input_file,
    mode,
    use_moses_tokenizer,
    moses_language,
    include_covered_msd,
):

    unimorph_df = pd.read_csv(
        unimorph_file,
        sep="\t",
        header=None,
        names=["lemma", "inflected_word", "msd"],
        encoding=ENCODING,
    )
    unimorph_inflected_words = set(unimorph_df["inflected_word"])

    if mode == "wordlist":
        input_df = pd.read_csv(
            input_file, sep="\t", header=None, names=["inflected_word"]
        )
        input_inflected_words = set(input_df["inflected_word"])
    else:
        if use_moses_tokenizer:
            tokenizer = sm.MosesTokenizer(lang=language)
            tokenize_fn = ft.partial(tokenize_with_sacremoses, tokenizer=tokenizer)
        else:
            tokenize_fn = split_on_whitespace

        input_inflected_words = get_inflected_words_from_text(
            input_file, tokenize=tokenize_fn
        )

    covered = unimorph_inflected_words.intersection(input_inflected_words)
    non_covered = input_inflected_words.difference(unimorph_inflected_words)
    coverage_ratio = round(len(covered) / (len(covered) + len(non_covered)), 3)

    result = {
        "words": {
            "covered": list(covered),
            "non_covered": list(non_covered),
        },
        "stats": {
            "num_covered": len(covered),
            "num_non_covered": len(non_covered),
            "coverage_ratio": coverage_ratio,
        },
    }

    if include_covered_msd:
        # create inflected word -> msd mapping for covered words
        covered_msd = {
            inflected_word: msd

            for _, inflected_word, msd in unimorph_df.itertuples(index=False)

            if inflected_word in covered
        }
        result["msd"] = covered_msd

    click.echo(json.dumps(result, indent=4, ensure_ascii=False))


if __name__ == "__main__":
    check_coverage()
