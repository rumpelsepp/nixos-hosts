#!/usr/bin/env python

import argparse
import binascii
import sys


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "HEX",
        nargs="+",
        type=binascii.unhexlify,
        help="hex values",
    )

    return parser.parse_args()


def main() -> None:
    args = parse_args()
    sys.stdout.buffer.write(b"".join(args.HEX))


if __name__ == "__main__":
    main()

