#!/usr/bin/env python3
"""MP3 Splitter - Split an MP3 file into equal parts."""

import argparse
import math
import os
import sys


def split_mp3(input_file: str, count: int) -> None:
    try:
        from pydub import AudioSegment
    except ImportError:
        print("Error: pydub is required. Install it with: pip install pydub")
        sys.exit(1)

    if not os.path.isfile(input_file):
        print(f"Error: File not found: {input_file}")
        sys.exit(1)

    if not input_file.lower().endswith(".mp3"):
        print(f"Error: File must be an MP3: {input_file}")
        sys.exit(1)

    if count < 1:
        print("Error: Count must be at least 1")
        sys.exit(1)

    print(f"Loading {input_file}...")
    audio = AudioSegment.from_mp3(input_file)
    total_ms = len(audio)
    chunk_ms = math.ceil(total_ms / count)

    base_name = os.path.splitext(os.path.basename(input_file))[0]
    output_dir = os.path.dirname(os.path.abspath(input_file))

    print(f"Duration: {total_ms / 1000:.1f}s — splitting into {count} parts...")

    for i in range(count):
        start = i * chunk_ms
        end = min(start + chunk_ms, total_ms)
        chunk = audio[start:end]

        output_file = os.path.join(output_dir, f"{base_name}_{i + 1:03d}.mp3")
        chunk.export(output_file, format="mp3")
        print(f"  [{i + 1}/{count}] {output_file} ({(end - start) / 1000:.1f}s)")

    print("Done.")


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="Splitter",
        description="Split an MP3 file into equal parts",
        add_help=False,
    )
    parser.add_argument("input_file", nargs="?", help="MP3 file to split")
    parser.add_argument("-c", "--count", type=int, help="Number of parts to split into")
    parser.add_argument("-h", "--help", action="store_true", help="Show this help message")

    args = parser.parse_args()

    if args.help or not args.input_file:
        print("Usage: Splitter <file.mp3> -c <count>")
        print()
        print("Parameters:")
        print("  file.mp3       MP3 file to split")
        print("  -c <count>     Number of parts to split into")
        print("  -h             Show this help message")
        print()
        print("Example:")
        print("  Splitter test.mp3 -c 3")
        sys.exit(0)

    if args.count is None:
        print("Error: -c <count> is required")
        print("Run 'Splitter -h' for usage.")
        sys.exit(1)

    split_mp3(args.input_file, args.count)


if __name__ == "__main__":
    main()
