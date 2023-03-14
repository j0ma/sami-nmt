#!/usr/bin/env python

import json
import pudb
import click
from pathlib import Path
from collections import Counter
from rich.progress import track


def construct_vocab(f):
    output = Counter()

    for sentence in track(f, description=f"Constructing vocab: {f.name}"):
        tokens = sentence.split(" ")
        output.update(tokens)

    return output


@click.command()
@click.argument("train_file", type=click.File(mode="r", encoding="utf-8"))
@click.argument("dev_file", type=click.File(mode="r", encoding="utf-8"))
@click.argument("test_file", type=click.File(mode="r", encoding="utf-8"))
def analyze_oov(train_file, dev_file, test_file):

    # construct vocabs from flies
    train_vocab = construct_vocab(train_file)
    dev_vocab = construct_vocab(dev_file)
    test_vocab = construct_vocab(test_file)

    train_dev_diff = dev_vocab - train_vocab
    train_test_diff = test_vocab - train_vocab

    train_dev_overlap = train_vocab & dev_vocab
    train_test_overlap = train_vocab & test_vocab
    train_dev_union = train_vocab | dev_vocab
    train_test_union = train_vocab | test_vocab

    dev_oov_rate = len(train_dev_diff) / len(dev_vocab)
    test_oov_rate = len(train_test_diff) / len(test_vocab)

    dev_iou_rate = len(train_dev_overlap) / len(train_dev_union)
    test_iou_rate = len(train_test_overlap) / len(train_test_union)

    out_json_dict = {
        "oov_dev": dev_oov_rate,
        "oov_test": test_oov_rate,
        "iou_dev": dev_iou_rate,
        "iou_test": test_iou_rate,
        "language": train_file.name.split(".")[-1]
    }
    out_json = json.dumps(out_json_dict)

    click.echo(out_json, nl=True)


if __name__ == "__main__":
    analyze_oov()
