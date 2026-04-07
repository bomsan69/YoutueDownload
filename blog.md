# 요즘 뜨는 CLI 만드는 법으로 YouTube MP3 추출기 만들기

목차
- 왜 지금 CLI인가
- 프로젝트 소개 및 기능
- 5분 만에 설치하기 (macOS/Linux)
- 코드 스니펫으로 이해하는 핵심 흐름
- Splitter `-i` 길이 확인 옵션 추가하기
- AI 에이전트(SKILL)와 연동하기
- 마치며

## 왜 지금 CLI인가
요즘은 “작게, 빠르게” 동작하는 CLI가 다시 유행입니다. 패키지 배포도 간단하고, 자동화 파이프라인에서 바로 호출할 수 있기 때문이죠. 여기서는 YouTube 오디오를 MP3로 추출하고 분할하는 두 가지 CLI(`ExtractAudio`, `Splitter`)를 예제로 다룹니다.

## 프로젝트 소개 및 기능
- `ExtractAudio`: YouTube URL → MP3 추출 (ffmpeg 번들 제공, 별도 설치 불필요)
- `Splitter`: MP3를 N개로 균등 분할하거나 `-i` 옵션으로 재생 길이만 확인
- 패키징: `pyproject.toml` + hatchling
- 최소 의존성: `yt-dlp`, `imageio-ffmpeg`

## 5분 만에 설치하기 (macOS/Linux)
### 1) 빠른 설치 (추천)
```bash
curl -fsSL https://raw.githubusercontent.com/bomsan69/YoutueDownload/master/install.sh | bash
```

### 2) 소스에서 설치
```bash
cd YoutueDownload
pipx install .   # 혹은 pip install -e .
```

### 3) `install.sh`를 직접 만들고 싶다면
아래 골격을 사용해 초보자도 쉽게 작성할 수 있습니다.
```bash
#!/usr/bin/env bash
set -euo pipefail

# 1) Python 3.10+ 확인
python3 - <<'PY'
import sys
major, minor = sys.version_info[:2]
assert major == 3 and minor >= 10, 'Python 3.10+ 필요'
PY

# 2) pipx 설치 (없으면)
command -v pipx >/dev/null 2>&1 || python3 -m pip install --user pipx
export PATH="$HOME/.local/bin:$PATH"

# 3) 패키지 설치
pipx install "git+https://github.com/bomsan69/YoutueDownload"

echo "설치 완료! 예: ExtractAudio \"https://youtu.be/xxx\""
```

## 코드 스니펫으로 이해하는 핵심 흐름
### ExtractAudio: 출력 경로와 ffmpeg 옵션 준비
```python
# src/youtuedownload/main.py (발췌)
def build_ydl_opts(output_dir: str, filename: str | None, ffmpeg_path: str) -> dict:
    name = os.path.splitext(filename)[0] if filename else datetime.now().strftime("youtube_%Y%m%d_%H%M%S")
    outtmpl = os.path.join(output_dir, f"{name}.%(ext)s")
    return {
        "format": "bestaudio/best",
        "outtmpl": outtmpl,
        "ffmpeg_location": ffmpeg_path,
        "postprocessors": [{"key": "FFmpegExtractAudio", "preferredcodec": "mp3", "preferredquality": "192"}],
    }
```

### Splitter: 길이 계산 후 균등 분할
```python
# src/splitter/splitter.py (발췌)
def split_mp3(input_file: str, count: int) -> None:
    validate_input_file(input_file)
    ffmpeg = get_ffmpeg()
    total = get_duration(ffmpeg, input_file)
    chunk = total / count
    for i in range(count):
        start = i * chunk
        duration = min(chunk, total - start)
        subprocess.run([ffmpeg, "-y", "-ss", str(start), "-t", str(duration), "-i", input_file, "-c", "copy", output_file], check=True)
```

## Splitter `-i` 길이 확인 옵션 추가하기
새로운 정보 모드로 재생 시간을 확인하고 종료합니다.
```python
if args.info:
    validate_input_file(args.input_file)
    ffmpeg = get_ffmpeg()
    total = get_duration(ffmpeg, args.input_file)
    print(f"파일: {args.input_file}")
    print(f"길이: {total:.1f}초")
    sys.exit(0)
```
실행 예시:
```bash
Splitter ~/Music/album.mp3 -i
```

## AI 에이전트(SKILL)와 연동하기
OpenAI 기반의 “openclaw 계열” 같은 에이전트에게 CLI 사용법을 주입하려면 `SKILL.md` 같은 메타 파일을 제공합니다. 아래 예시는 이 저장소의 CLI를 호출하는 방법을 기술한 스킬 문서입니다. 에이전트는 스킬을 읽고 적절한 명령을 실행하게 됩니다.

### 예시 흐름
1) 에이전트가 `SKILL.md`를 로드한다.
2) 사용자가 “이 동영상에서 오디오를 뽑아줘”라고 말하면, 스킬에 정의된 명령을 따라 `ExtractAudio "<url>" -d /tmp`를 실행한다.
3) 사용자가 “이 MP3 길이만 알려줘”라고 하면 `Splitter file.mp3 -i`를 실행한다.

자세한 스킬 정의는 같은 디렉토리의 `SKILL.md`를 참고하세요.

## 마치며
간단한 CLI 두 개로도 다운로드·분할·길이 조회까지 모두 해결할 수 있습니다. `install.sh`를 곁들이면 배포도 쉬워지고, SKILL 문서까지 준비하면 요즘 유행하는 에이전트에게도 바로 일을 시킬 수 있습니다.
