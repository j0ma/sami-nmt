from pathlib import Path
import sys

def oov_rate(train, held_out):
    train = set(train)
    held_out = set(held_out)
    oov = held_out - train
    return len(oov) / len(held_out), oov

def get_vocab(fp):
    lines = []
    with open(fp) as f:
        for line in f:
            for tok in line.split(" "):
                lines.append(tok.strip())
    return lines

def main():
    train, held_out = sys.argv[1:3]
    vocab_train = read_text(train)
    vocab_held_out = read_text(held_out)

    oov_r, oovs = oov_rate(vocab_train, vocab_held_out)
    oov_r = round(oov_r, 3)

    print(f"{train}\t{held_out}\t{oov_r}")

    print("Here are some OOVs:")
    print("\n".join(list(oovs)[:10]))

if __name__ == "__main__":
    main()
