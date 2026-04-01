# ExtractAudio

YouTube URL에서 MP3 오디오를 추출하는 macOS CLI 도구

## 설치

```bash
pip install -e .
# 또는
uv pip install -e .
```

> ffmpeg를 별도로 설치할 필요 없습니다. `imageio-ffmpeg` 패키지가 자동으로 제공합니다.

## 사용법

```
ExtractAudio <youtube_url> [-d directory] [-name filename] [-h]
```

### 옵션

| 옵션 | 설명 |
|------|------|
| `url` | YouTube URL (필수) |
| `-d <directory>` | 저장 디렉토리 (기본값: 현재 디렉토리) |
| `-name <filename>` | 파일명 지정, `.mp3` 자동 추가 (기본값: `youtube_YYYYMMDD_HHMMSS`) |
| `-h, --help` | 사용법 출력 |

### 예시

```bash
# 기본 사용 (현재 디렉토리에 YouTube 타이틀로 저장)
ExtractAudio "https://youtu.be/WbHDsHqt6ug?si=CtCzTih3jWf7XAC1"

# 저장 디렉토리 지정
ExtractAudio "https://youtu.be/WbHDsHqt6ug" -d ~/Music

# 파일명 지정
ExtractAudio "https://youtu.be/WbHDsHqt6ug" -name my_song

# 디렉토리 + 파일명 모두 지정
ExtractAudio "https://youtu.be/WbHDsHqt6ug" -d ~/Music -name my_song
```

> **주의:** URL에 `?` 또는 `&`가 포함된 경우 반드시 따옴표(`"`)로 감싸야 합니다.
> zsh 셸이 해당 문자를 파일 패턴으로 해석하기 때문입니다.
