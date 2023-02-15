import itertools as it
import sys
from collections import defaultdict
from typing import Dict, List, Optional, Set, TextIO, Tuple

import attr
import click
import editdistance
import jiwer
import numpy as np
import pandas as pd
import sacrebleu
from paranames.util import read as read_df
from tqdm import tqdm

"""Evaluate 2.0

Computes 5 evaluation metrics for translated words:
    - Token Accuracy
    - 1 - Token Accuracy
    - BLEU

All scores are normalized to lie in the range [0, 1].
"""


def read_text(path: str) -> TextIO:
    return open(path, encoding="utf-8")


@attr.s(kw_only=True)  # kw_only ensures we are explicit
class TranslationOutput:
    """Represents a single translation output, consisting of a
    source language and line, reference translation and a model hypothesis.
    """

    language: str = attr.ib()
    reference: str = attr.ib()
    hypothesis: str = attr.ib()
    source: str = attr.ib(default="")


@attr.s(kw_only=True)
class TranslationMetrics:
    """Score container for a collection of translation results.

    Contains
    - Token Accuracy
    - 1 - Token Accuracy
    - BLEU
    """

    token_acc: float = attr.ib(factory=float)
    token_err: float = attr.ib(default=1.0)
    bleu: float = attr.ib(factory=float)
    rounding: int = attr.ib(default=5)
    language: str = attr.ib(default="")

    def __attrs_post_init__(self) -> None:
        self.token_acc = round(self.token_acc, self.rounding)
        self.token_err = round(self.token_err, self.rounding)
        self.bleu = round(self.bleu, self.rounding)

    def format(self) -> str:
        """Format like in old evaluate.py"""

        out = """Token Accuracy\t{token_acc:.4f}
WER\t{token_err:.4f}
BLEU\t{bleu:.4f}\n\n""".format(
            token_acc=self.token_acc,
            token_err=self.token_err,
            bleu=self.bleu,
        )

        return out


@attr.s(kw_only=True)
class TranslationResults:
    system_outputs: List[TranslationOutput] = attr.ib(factory=list)
    metrics: TranslationMetrics = attr.ib(factory=TranslationMetrics)

    def __attrs_post_init__(self) -> None:
        self.metrics = self.compute_metrics()

    def compute_metrics(self) -> TranslationMetrics:
        unique_languages = set([o.language for o in self.system_outputs])

        if len(unique_languages) > 1:
            language = "global"
        else:
            language = list(unique_languages)[0]

        token_acc = 100 * self.token_accuracy(self.system_outputs)
        token_err = 100 - token_acc
        bleu = 100 * self.bleu(self.system_outputs)

        metrics = TranslationMetrics(
            token_acc=token_acc,
            token_err=token_err,
            bleu=bleu,
            language=language,
        )

        return metrics

    def token_accuracy(self, system_outputs: List[TranslationOutput]) -> float:
        return np.mean([int(o.reference == o.hypothesis) for o in system_outputs])

    def bleu(self, system_outputs: List[TranslationOutput]) -> float:
        hypotheses = [o.hypothesis for o in system_outputs]
        references = [[o.reference for o in system_outputs]]
        bleu = sacrebleu.corpus_bleu(hypotheses, references, force=True)

        return bleu.score / 100.0  # divide to normalize


@attr.s(kw_only=True)
class ExperimentResults:
    system_outputs: List[TranslationOutput] = attr.ib(factory=list)
    languages: Set[str] = attr.ib(factory=set)
    grouped: bool = attr.ib(default=True)
    metrics_dict: Dict[str, TranslationResults] = attr.ib(factory=dict)

    def __attrs_post_init__(self) -> None:
        self.metrics_dict = self.compute_metrics_dict()

    def compute_metrics_dict(self) -> Dict[str, TranslationResults]:

        metrics = {}

        # first compute global metrics
        metrics["global"] = TranslationResults(system_outputs=self.system_outputs)

        # then compute one for each lang

        for lang in tqdm(self.languages, total=len(self.languages)):
            filtered_outputs = [o for o in self.system_outputs if o.language == lang]
            metrics[lang] = TranslationResults(system_outputs=filtered_outputs)

        return metrics

    @classmethod
    def outputs_from_paths(
        cls,
        references_path: str,
        hypotheses_path: str,
        source_path: str,
        languages_path: str,
    ) -> Tuple[List[TranslationOutput], Set[str]]:
        def global_lang_generator():
            while True:
                yield "global"

        langs_iterator = (
            read_text(languages_path) if languages_path else global_lang_generator()
        )
        hyps_iterator = read_text(hypotheses_path)
        refs_iterator = read_text(references_path)
        src_iterator = read_text(source_path)

        languages = set()
        system_outputs = []

        from itertools import zip_longest

        for line in zip(hyps_iterator, refs_iterator, src_iterator, langs_iterator):

            hyp_line, ref_line, src_line, langs_line = line

            # grab hypothesis lines
            hypothesis = hyp_line.strip()
            reference = ref_line.strip()
            source = src_line.strip()
            language = "global" if not langs_line else langs_line.strip()
            languages.add(language)
            system_outputs.append(
                TranslationOutput(
                    language=language,
                    reference=reference,
                    hypothesis=hypothesis,
                    source=source,
                )
            )

        return system_outputs, languages

    @classmethod
    def outputs_from_combined_tsv(
        cls, combined_tsv_path: str
    ) -> Tuple[List[TranslationOutput], Set[str]]:

        combined_tsv = read_df(
            combined_tsv_path,
            io_format="tsv",
            column_names=["ref", "hyp", "src", "language"],
            quoting=3,
        ).astype(str)

        languages = set()
        system_outputs = []

        for hypothesis, reference, source, language in tqdm(
            zip(
                combined_tsv.hyp,
                combined_tsv.ref,
                combined_tsv.src,
                combined_tsv.language,
            ),
            total=combined_tsv.shape[0],
        ):

            # grab hypothesis lines
            languages.add(language)
            system_outputs.append(
                TranslationOutput(
                    language=language,
                    reference=reference,
                    hypothesis=hypothesis,
                    source=source,
                )
            )

        return system_outputs, languages

    @classmethod
    def from_paths(
        cls,
        references_path: str,
        hypotheses_path: str,
        source_path: str,
        languages_path: str,
        grouped: bool = True,
    ):
        system_outputs, languages = cls.outputs_from_paths(
            references_path=references_path,
            hypotheses_path=hypotheses_path,
            source_path=source_path,
            languages_path=languages_path,
        )

        return ExperimentResults(
            system_outputs=system_outputs, grouped=grouped, languages=languages
        )

    @classmethod
    def from_tsv(
        cls,
        tsv_path: str,
        grouped: bool = True,
    ):
        system_outputs, languages = cls.outputs_from_combined_tsv(tsv_path)

        return ExperimentResults(
            system_outputs=system_outputs, grouped=grouped, languages=languages
        )

    def as_data_frame(self):
        _languages = self.languages | set(["global"])

        rows = [attr.asdict(self.metrics_dict[lang].metrics) for lang in _languages]
        out = (
            pd.DataFrame(rows)
            .drop(columns=["rounding", "token_err"])
            .rename(
                columns={
                    "token_acc": "Accuracy",
                    "language": "Language",
                    "bleu": "BLEU",
                }
            )
            .round(3)
        )

        return out


@click.command()
@click.option("--references-path", "--gold-path", "--ref", "--gold", default="")
@click.option("--hypotheses-path", "--hyp", default="")
@click.option("--source-path", "--src", default="")
@click.option("--languages-path", "--langs", default="")
@click.option("--combined-tsv-path", "--tsv", default="")
@click.option("--score-output-path", "--score", default="/dev/stdout")
@click.option("--output-as-tsv", is_flag=True)
@click.option("--output-as-json", is_flag=True)
def main(
    references_path: str,
    hypotheses_path: str,
    source_path: str,
    languages_path: str,
    combined_tsv_path: str,
    score_output_path: str,
    output_as_tsv: bool,
    output_as_json: bool,
):

    if combined_tsv_path:
        results = ExperimentResults.from_tsv(tsv_path=combined_tsv_path)
    else:
        results = ExperimentResults.from_paths(
            references_path=references_path,
            hypotheses_path=hypotheses_path,
            source_path=source_path,
            languages_path=languages_path,
        )

    if output_as_tsv:
        result_df = results.as_data_frame()
        result_df.to_csv(score_output_path, index=False, sep="\t")
    else:
        with (
            open(score_output_path, "w", encoding="utf-8")

            if score_output_path
            else sys.stdout
        ) as score_out_file:
            for lang in results.languages:
                score_out_file.write(f"{lang}:\n")
                score_out_file.write(results.metrics_dict.get(lang).metrics.format())

            # finally write out global
            score_out_file.write("global:\n")
            score_out_file.write(results.metrics_dict.get("global").metrics.format())


if __name__ == "__main__":
    main()
