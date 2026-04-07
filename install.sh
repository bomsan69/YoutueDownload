#!/usr/bin/env bash

REPO_URL="https://github.com/bomsan69/YoutueDownload"
MIN_PYTHON_MINOR=10  # Python 3.10+

# ── 색상 출력 ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${GREEN}[✔]${NC} $1"; }
step()    { echo -e "${BLUE}[→]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✘]${NC} $1"; exit 1; }

# ── OS 감지 ───────────────────────────────────────────────
detect_os() {
    step "운영체제 감지 중..."
    case "$(uname -s)" in
        Darwin)
            OS="macos"
            info "macOS 감지됨"
            ;;
        Linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                OS="linux"
                DISTRO="${ID:-unknown}"
                info "Linux 감지됨 (${DISTRO})"
            else
                error "지원하지 않는 Linux 배포판입니다."
            fi
            ;;
        *)
            error "지원하지 않는 운영체제입니다. (macOS / Linux만 지원)"
            ;;
    esac
}

# ── Python 확인 ───────────────────────────────────────────
check_python() {
    step "Python 확인 중..."
    PYTHON=""
    for cmd in python3 python; do
        if command -v "$cmd" &>/dev/null; then
            major=$("$cmd" -c 'import sys; print(sys.version_info.major)' 2>/dev/null || echo 0)
            minor=$("$cmd" -c 'import sys; print(sys.version_info.minor)' 2>/dev/null || echo 0)
            if [ "$major" -eq 3 ] && [ "$minor" -ge "$MIN_PYTHON_MINOR" ]; then
                PYTHON="$cmd"
                info "Python $($PYTHON --version) 확인됨"
                return
            fi
        fi
    done

    echo ""
    echo "  Python 3.${MIN_PYTHON_MINOR}+ 이 필요합니다."
    echo "  설치 방법:"
    echo "    macOS:  brew install python"
    echo "    Ubuntu: sudo apt install python3"
    echo ""
    exit 1
}

# ── pipx 확인 및 설치 ─────────────────────────────────────
install_pipx() {
    step "pipx 확인 중..."

    # PATH에 ~/.local/bin 포함 (pipx가 여기 설치될 수 있음)
    export PATH="$HOME/.local/bin:$PATH"

    if command -v pipx &>/dev/null; then
        info "pipx 이미 설치됨 ($(pipx --version))"
        return
    fi

    step "pipx 설치 중..."

    if [ "$OS" = "macos" ]; then
        if command -v brew &>/dev/null; then
            brew install pipx || error "pipx 설치 실패. 수동으로 설치하세요: brew install pipx"
        else
            warn "Homebrew가 없습니다. pip으로 pipx를 설치합니다."
            $PYTHON -m pip install --user pipx || error "pipx 설치 실패"
        fi

    elif [ "$OS" = "linux" ]; then
        if command -v apt-get &>/dev/null; then
            if apt-cache show pipx &>/dev/null 2>&1; then
                sudo apt-get install -y pipx || error "pipx 설치 실패"
            else
                warn "apt에 pipx가 없습니다. pip으로 설치합니다."
                $PYTHON -m pip install --user pipx || error "pipx 설치 실패"
            fi
        else
            $PYTHON -m pip install --user pipx || error "pipx 설치 실패"
        fi
    fi

    # 설치 후 PATH 재확인
    export PATH="$HOME/.local/bin:$PATH"
    hash -r 2>/dev/null || true

    if ! command -v pipx &>/dev/null; then
        error "pipx 설치 후에도 명령을 찾을 수 없습니다.\n  PATH에 ~/.local/bin 이 포함되어 있는지 확인하세요."
    fi

    info "pipx 설치 완료 ($(pipx --version))"
}

# ── ExtractAudio 설치 ─────────────────────────────────────
install_extractaudio() {
    step "ExtractAudio 설치 중..."

    # 기존 설치 제거
    if pipx list 2>/dev/null | grep -q "youtuedownload"; then
        warn "기존 버전을 제거하고 재설치합니다."
        pipx uninstall youtuedownload 2>/dev/null || true
    fi

    if ! pipx install "git+${REPO_URL}"; then
        echo ""
        echo "  설치에 실패했습니다. 아래를 확인하세요:"
        echo "    1. 인터넷 연결 상태"
        echo "    2. git 설치 여부: git --version"
        echo ""
        exit 1
    fi

    info "ExtractAudio 설치 완료"
}

# ── PATH 등록 ─────────────────────────────────────────────
setup_path() {
    step "PATH 등록 중..."
    pipx ensurepath 2>/dev/null || true

    # 셸 설정 파일 감지
    SHELL_RC=""
    case "${SHELL:-}" in
        */zsh)  SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bashrc" ;;
    esac

    echo ""
    echo "======================================"
    info "설치 완료!"
    echo "======================================"
    echo ""
    echo "  새 터미널을 열거나 아래 명령을 실행하세요:"
    echo ""
    if [ -n "$SHELL_RC" ]; then
        echo "    source ${SHELL_RC}"
    else
        echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
    echo ""
    echo "  사용법:"
    echo '    ExtractAudio "https://youtu.be/VIDEO_ID"'
    echo '    ExtractAudio --help'
    echo ""
    echo '    Splitter file.mp3 -c 3'
    echo '    Splitter -h'
    echo ""
}

# ── 메인 ──────────────────────────────────────────────────
main() {
    echo ""
    echo "======================================"
    echo "  YoutueDownload Tools 설치 스크립트"
    echo "======================================"
    echo ""
    detect_os
    check_python
    install_pipx
    install_extractaudio
    setup_path
}

main
