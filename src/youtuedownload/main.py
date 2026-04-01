import argparse
import os
import sys
from datetime import datetime

import imageio_ffmpeg
import yt_dlp


def parse_args():
    parser = argparse.ArgumentParser(
        prog="ExtractAudio",
        description="YouTube URL에서 MP3 오디오를 추출합니다.",
        formatter_class=argparse.RawTextHelpFormatter,
        epilog=(
            "예시:\n"
            '  ExtractAudio "https://youtu.be/WbHDsHqt6ug?si=xxx"\n'
            '  ExtractAudio "https://youtu.be/WbHDsHqt6ug" -d ~/Music\n'
            '  ExtractAudio "https://youtu.be/WbHDsHqt6ug" -name my_song\n'
            '  ExtractAudio "https://youtu.be/WbHDsHqt6ug" -d ~/Music -name my_song\n'
            "\n"
            "주의: URL에 ? 또는 & 가 포함된 경우 따옴표로 감싸야 합니다.\n"
        ),
    )
    parser.add_argument("url", help="YouTube URL")
    parser.add_argument(
        "-d",
        metavar="directory",
        default=None,
        help="MP3 파일을 저장할 디렉토리 (기본값: 현재 디렉토리)",
    )
    parser.add_argument(
        "-name",
        metavar="filename",
        default=None,
        help="저장할 파일명 (.mp3 확장자 자동 추가, 기본값: YouTube 타이틀)",
    )
    return parser.parse_args()


def resolve_output_dir(directory: str | None) -> str:
    if directory is None:
        return os.getcwd()
    path = os.path.expanduser(directory)
    if not os.path.exists(path):
        print(f"오류: 디렉토리를 찾을 수 없습니다 — {path}")
        sys.exit(1)
    if not os.path.isdir(path):
        print(f"오류: 경로가 디렉토리가 아닙니다 — {path}")
        sys.exit(1)
    return path


def build_ydl_opts(output_dir: str, filename: str | None, ffmpeg_path: str) -> dict:
    if filename is not None:
        # 확장자 제거 후 .mp3 자동 추가
        name = os.path.splitext(filename)[0]
    else:
        name = datetime.now().strftime("youtube_%Y%m%d_%H%M%S")
    outtmpl = os.path.join(output_dir, f"{name}.%(ext)s")

    return {
        "format": "bestaudio/best",
        "outtmpl": outtmpl,
        "ffmpeg_location": ffmpeg_path,
        "postprocessors": [
            {
                "key": "FFmpegExtractAudio",
                "preferredcodec": "mp3",
                "preferredquality": "192",
            }
        ],
        "quiet": False,
        "no_warnings": False,
    }


def main():
    args = parse_args()

    output_dir = resolve_output_dir(args.d)
    ffmpeg_path = imageio_ffmpeg.get_ffmpeg_exe()
    ydl_opts = build_ydl_opts(output_dir, args.name, ffmpeg_path)

    print(f"다운로드 중: {args.url}")
    print(f"저장 위치: {output_dir}")

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download([args.url])
        print("완료!")
    except yt_dlp.utils.DownloadError as e:
        print(f"다운로드 오류: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
