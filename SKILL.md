# Skill: YoutueDownload CLI Helper

## 목적
에이전트가 이 저장소의 CLI 도구(`ExtractAudio`, `Splitter`)를 자동으로 실행해 YouTube 오디오 추출, MP3 분할, 길이 정보 확인을 수행하도록 안내합니다. macOS/Linux 환경을 전제로 합니다.

## 전제 조건
- Python 3.10+ (프로젝트는 3.13 사용) 설치 및 PATH 노출
- `pipx` 또는 `pip` 사용 가능
- ffmpeg는 `imageio-ffmpeg`로 번들 제공 (별도 설치 불필요)

## 설치/업데이트 명령
- 빠른 설치: `curl -fsSL https://raw.githubusercontent.com/bomsan69/YoutueDownload/master/install.sh | bash`
- 소스 설치: `pipx install .` (repo 루트) 또는 `pip install -e .`
- 재설치: `pipx uninstall youtuedownload && pipx install .`

## 사용 명령 (에이전트가 실행할 것)
- 오디오 추출: `ExtractAudio "<youtube_url>" [-d <dir>] [-name <filename>]`
- 길이 확인: `Splitter <file.mp3> -i`
- 분할: `Splitter <file.mp3> -c <count>`
- 헬프: `ExtractAudio --help`, `Splitter -h`

## 처리 규칙
- URL에 `?` 또는 `&`가 있으면 반드시 따옴표로 감싼다.
- 파일이 없거나 확장자가 `.mp3`가 아니면 오류를 출력하고 중단한다.
- 실패 시 비밀번호나 토큰을 요청하지 말고, stderr 메시지를 그대로 전달한다.

## 예시 시나리오
1) 사용자: “이 링크 오디오를 /tmp에 저장해줘”
   - 명령: `ExtractAudio "https://youtu.be/VIDEO" -d /tmp`
2) 사용자: “이 MP3 길이만 알려줘”
   - 명령: `Splitter /tmp/audio.mp3 -i`
3) 사용자: “MP3를 3개로 쪼개줘”
   - 명령: `Splitter /tmp/audio.mp3 -c 3`

## 로깅/보고
- 에이전트는 실행한 명령과 결과(성공/실패, 출력 경로, 파일 리스트)를 간단히 요약해 보고한다.
- 긴 다운로드는 시간이 걸릴 수 있음을 알린다.

## 제약
- 네트워크가 필요한 작업은 YouTube 다운로드뿐이다.
- Windows는 공식 지원 대상이 아니다.

## 참조
- 프로젝트 루트의 `AGENTS.md`, `README.md`, `install.sh`.
