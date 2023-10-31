#!/usr/bin/env python

import click
from pathlib import Path


@click.command()
@click.option("--debug", is_flag=True)
@click.argument("input_file", type=click.Path(exists=True, dir_okay=False))
def unique_lines(input_file, debug):
    """Read lines from a file and output unique lines without sorting."""
    seen_lines = set()
    with Path(input_file).open("r") as file:
        for line in file:
            stripped_line = line.strip()
            if stripped_line not in seen_lines:
                seen_lines.add(stripped_line)
                click.echo(stripped_line)
            elif debug:
                click.echo(f"Skipping: {stripped_line}", err=True)


if __name__ == "__main__":
    unique_lines()
