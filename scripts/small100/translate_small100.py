import click
from pathlib import Path
from transformers import M2M100ForConditionalGeneration
from tokenization_small100 import SMALL100Tokenizer


def translate_text(texts, target_language, batch_size):
    model = M2M100ForConditionalGeneration.from_pretrained("alirezamsh/small100")
    tokenizer = SMALL100Tokenizer.from_pretrained("alirezamsh/small100")

    tokenizer.tgt_lang = target_language
    translated_texts = []

    for i in range(0, len(texts), batch_size):
        batch_texts = texts[i : i + batch_size]
        encoded_texts = tokenizer(
            batch_texts,
            return_tensors="pt",
            padding=True,
            truncation=True,
            max_length=512,
        )
        generated_tokens = model.generate(**encoded_texts)
        translated_texts.extend(
            tokenizer.batch_decode(generated_tokens, skip_special_tokens=True)
        )

    return translated_texts


@click.command()
@click.option(
    "--input-file",
    type=click.File("r"),
    default="-",
)
@click.option(
    "--output-file",
    type=click.File("w"),
    default="-",
    help="Output file path",
)
@click.option(
    "--target_language", type=str, default="en", help="Target language for translation"
)
@click.option("--batch_size", type=int, default=1, help="Batch size for translation")
def main(input_file, output_file, target_language, batch_size):
    stdin = click.get_text_stream("stdin")
    stdout = click.get_text_stream("stdout")

    with (input_file or stdin) as fin:
        texts = [line.strip() for line in fin]

    translated_texts = translate_text(texts, target_language, batch_size)

    with (output_file or stdout) as fout:
        click.echo("\n".join(translated_texts), file=fout)


if __name__ == "__main__":
    main()
