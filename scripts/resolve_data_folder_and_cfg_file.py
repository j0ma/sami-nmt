#!/usr/bin/env python

# Description: this script uses a YAMl file to resolve the path to the data folder and experiment config file

from pathlib import Path
from typing import Any
import json

import yaml
import click


def load_yaml_to_dict(path: Path) -> dict[str, Any]:
    with open(path, "r") as f:
        return yaml.safe_load(f)


@click.command()
@click.option("--train-data-type")
@click.option(
    "--direction",
)
@click.option(
    "--yaml-lookup-file",
    default="config/data_and_cfg_mapping.yaml",
    type=click.Path(path_type=Path),
)
@click.option("--raw-data-key", default="randseg_raw_data_folder")
@click.option("--cfg-file-key", default="randseg_cfg_file")
def main(train_data_type, direction, yaml_lookup_file, raw_data_key, cfg_file_key):
    assert yaml_lookup_file.exists(), f"{yaml_lookup_file} does not exist"

    # load yaml file
    lookup_table = load_yaml_to_dict(yaml_lookup_file)
    subtable = lookup_table[direction][train_data_type]
    data_folder = Path(subtable[raw_data_key]).resolve()
    cfg_file = Path(subtable[cfg_file_key]).resolve()

    json_out = {"data_folder": str(data_folder), "cfg_file": str(cfg_file)}
    click.echo(json.dumps(json_out))


if __name__ == "__main__":
    main()
