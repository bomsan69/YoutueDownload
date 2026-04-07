#!/usr/bin/env python3
"""MP3 Splitter - Split an MP3 file into equal parts using ffmpeg."""

import argparse
import json
import math
import os
import subprocess
import sys


def get_ffmpeg():
    try:
        import imageio_ffmpeg
        return imageio_ffmpeg.get_ffmpeg_exe()
    except ImportError:
        pass

    for cmd in ("ffmpeg", "/usr/local/bin/ffmpeg", "/opt/homebrew/bin/ffmpeg"):
        try:
            subprocess.run([cmd, "-version"], capture_output=True, check=True)
            return cmd
        except (FileNotFoundError, subprocess.CalledProcessError):
            continue

    print("Error: ffmpeg를 찾을 수 없습니다. 'pip install imageio-ffmpeg' 로 설치하세요.")
    sys.exit(1)


def get_duration(ffmpeg: str, input_file: str) -> float:
    ffprobe = ffmpeg.replace("ffmpeg", "ffprobe")
    # ffprobe가 없으면 ffmpeg로 duration 파싱
    try:
        result = subprocess.run(
            [ffprobe, "-v", "quiet", "-print_format", "json", "-show_format", input_file],
            capture_output=True, text=True, check=True,
        )
        info = json.loads(result.stdout)
        return float(info["format"]["duration"])
    except (FileNotFoundError, subprocess.CalledProcessError, KeyError):
        pass

    # fallback: ffmpeg stderr 파싱
    result = subprocess.run(
        [ffmpeg, "-i", input_file],
        capture_output=True, text=True,
    )
    for line in result.stderr.splitlines():
        if "Duration:" in line:
            time_str = line.split("Duration:")[1].split(",")[0].strip()
            h, m, s = time_str.split(":")
            return int(h) * 3600 + int(m) * 60 + float(s)

    print("Error: 파일 길이를 읽을 수 없습니다.")
    sys.exit(1)


def validate_input_file(input_file: str) -> None:
    if not os.path.isfile(input_file):
        print(f"Error: 파일을 찾을 수 없습니다: {input_file}")
        sys.exit(1)

    if not input_file.lower().endswith(".mp3"):
        print(f"Error: MP3 파일이어야 합니다: {input_file}")
        sys.exit(1)


def split_mp3(input_file: str, count: int) -> None:
    validate_input_file(input_file)

    if count < 1:
        print("Error: 분할 수는 1 이상이어야 합니다.")
        sys.exit(1)

    ffmpeg = get_ffmpeg()
    total = get_duration(ffmpeg, input_file)
    chunk = total / count

    base_name = os.path.splitext(os.path.basename(input_file))[0]
    output_dir = os.path.dirname(os.path.abspath(input_file))

    print(f"파일: {input_file}")
    print(f"길이: {total:.1f}초 → {count}개 분할 ({chunk:.1f}초/개)")
    print()

    for i in range(count):
        start = i * chunk
        duration = min(chunk, total - start)
        output_file = os.path.join(output_dir, f"{base_name}_{i + 1:03d}.mp3")

        subprocess.run(
            [
                ffmpeg, "-y",
                "-ss", str(start),
                "-t", str(duration),
                "-i", input_file,
                "-c", "copy",
                output_file,
            ],
            capture_output=True,
            check=True,
        )
        print(f"  [{i + 1}/{count}] {os.path.basename(output_file)} ({duration:.1f}초)")

    print()
    print("완료.")


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="Splitter",
        description="MP3 파일을 균등하게 분할합니다",
        add_help=False,
    )
    parser.add_argument("input_file", nargs="?", help="분할할 MP3 파일")
    parser.add_argument("-c", "--count", type=int, help="분할할 파일 수")
    parser.add_argument("-i", "--info", action="store_true", help="파일 길이 정보 출력")
    parser.add_argument("-h", "--help", action="store_true", help="사용법 출력")

    args = parser.parse_args()

    if args.help or not args.input_file:
        print("사용법: Splitter <file.mp3> -c <count> [-i]")
        print()
        print("파라미터:")
        print("  file.mp3       분할할 MP3 파일")
        print("  -c <count>     분할할 파일 수")
        print("  -i             파일 길이 정보 출력")
        print("  -h             사용법 출력")
        print()
        print("예시:")
        print("  Splitter test.mp3 -c 3")
        print("  Splitter test.mp3 -i")
        sys.exit(0)

    if args.info:
        validate_input_file(args.input_file)
        ffmpeg = get_ffmpeg()
        total = get_duration(ffmpeg, args.input_file)
        print(f"파일: {args.input_file}")
        print(f"길이: {total:.1f}초")
        sys.exit(0)

    if args.count is None:
        print("Error: -c <count> 옵션이 필요합니다.")
        print("'Splitter -h' 로 사용법을 확인하세요.")
        sys.exit(1)

    split_mp3(args.input_file, args.count)


if __name__ == "__main__":
    main()
