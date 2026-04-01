#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/bomsan69/YoutueDownload"
MIN_PYTHON_MINOR=10  # Python 3.10+

# ── 색상 출력 ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ── OS 감지 ───────────────────────────────────────────────
detect_os() {
    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                OS="linux"
                DISTRO="${ID:-unknown}"
            else
                error "지원하지 않는 Linux 배포판입니다."
            fi
            ;;
        *) error "지원하지 않는 운영체제입니다. (macOS / Ubuntu만 지원)" ;;
    esac
    info "OS 감지: ${OS}${DISTRO:+ ($DISTRO)}"
}

# ── Python 확인 ───────────────────────────────────────────
check_python() {
    PYTHON=""
    for cmd in python3 python; do
        if command -v "$cmd" &>/dev/null; then
            version=$("$cmd" -c 'import sys; print(sys.version_info.minor)' 2>/dev/null)
            major=$("$cmd" -c 'import sys; print(sys.version_info.major)' 2>/dev/null)
            if [ "$major" -eq 3 ] && [ "$version" -ge "$MIN_PYTHON_MINOR" ]; then
                PYTHON="$cmd"
                info "Python 확인: $($PYTHON --version)"
                return
            fi
        fi
    done

    error "Python 3.${MIN_PYTHON_MINOR}+ 이 필요합니다.\n\
  macOS:  brew install python\n\
  Ubuntu: sudo apt install python3"
}

# ── pipx 설치 ─────────────────────────────────────────────
install_pipx() {
    if command -v pipx &>/dev/null; then
        info "pipx 이미 설치됨: $(pipx --version)"
        return
    fi

    info "pipx 설치 중..."

    if [ "$OS" = "macos" ]; then
        if command -v brew &>/dev/null; then
            brew install pipx
        else
            error "Homebrew가 설치되어 있지 않습니다.\n먼저 https://brew.sh 에서 Homebrew를 설치하세요."
        fi

    elif [ "$OS" = "linux" ]; then
        if command -v apt-get &>/dev/null; then
            # Ubuntu 23.04+ 는 apt로 pipx 제공
            if apt-cache show pipx &>/dev/null 2>&1; then
                sudo apt-get install -y pipx
            else
                # 구버전 Ubuntu: pip으로 설치
                $PYTHON -m pip install --user pipx
            fi
        else
            $PYTHON -m pip install --user pipx
        fi
    fi

    # PATH 즉시 반영
    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v pipx &>/dev/null; then
        error "pipx 설치에 실패했습니다."
    fi
    info "pipx 설치 완료: $(pipx --version)"
}

# ── ExtractAudio 설치 ─────────────────────────────────────
install_extractaudio() {
    info "ExtractAudio 설치 중..."

    # 이미 설치된 경우 재설치
    if pipx list | grep -q "youtuedownload"; then
        warn "이미 설치되어 있습니다. 최신 버전으로 재설치합니다."
        pipx uninstall youtuedownload 2>/dev/null || true
    fi

    pipx install "git+${REPO_URL}"
    info "ExtractAudio 설치 완료"
}

# ── PATH 등록 ─────────────────────────────────────────────
setup_path() {
    pipx ensurepath

    # 현재 셸 설정 파일에 반영 안내
    SHELL_RC=""
    case "$SHELL" in
        */zsh)  SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bashrc" ;;
    esac

    echo ""
    info "설치가 완료되었습니다!"
    echo ""
    echo "  새 터미널을 열거나 아래 명령을 실행하세요:"
    if [ -n "$SHELL_RC" ]; then
        echo ""
        echo "    source ${SHELL_RC}"
    else
        echo ""
        echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
    echo ""
    echo "  사용법:"
    echo '    ExtractAudio "https://youtu.be/VIDEO_ID"'
    echo '    ExtractAudio --help'
    echo ""
}

# ── 메인 ──────────────────────────────────────────────────
main() {
    echo "======================================"
    echo "  ExtractAudio 설치 스크립트"
    echo "======================================"
    echo ""
    detect_os
    check_python
    install_pipx
    install_extractaudio
    setup_path
}

main
