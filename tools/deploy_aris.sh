#!/bin/bash
set -euo pipefail

# ============================================================
#  ARIS 一键部署脚本 (RobWonn 自定义版本 - 含 thinking 支持)
# ============================================================
#
#  用法:
#    方式一: 从源码编译安装 (需要 Rust 工具链)
#      bash deploy_aris.sh --from-source
#
#    方式二: 使用预编译二进制 (需要先上传到 GitHub Release)
#      bash deploy_aris.sh
#
#    方式三: 只安装 skills (不安装 aris 二进制)
#      bash deploy_aris.sh --skills-only
#
# ============================================================

GITHUB_USER="RobWonn"
REPO_NAME="Auto-claude-code-research-in-sleep"
REPO_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
REPO_SSH="git@github.com:${GITHUB_USER}/${REPO_NAME}.git"
BRANCH_CODE="aris-code"
TAG="v0.4.4-thinking"

SKILLS_TARGET="$HOME/.claude/skills"
INSTALL_DIR="/usr/local/bin"
TEMP_DIR=$(mktemp -d)

trap "rm -rf $TEMP_DIR" EXIT

info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
ok()    { echo -e "\033[1;32m[OK]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
err()   { echo -e "\033[1;31m[ERROR]\033[0m $*"; exit 1; }

install_skills() {
    info "安装 ARIS skills..."
    if [ -d "$TEMP_DIR/repo" ]; then
        REPO_DIR="$TEMP_DIR/repo"
    else
        info "克隆仓库 (main 分支)..."
        git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo" 2>/dev/null || \
        git clone --depth 1 "$REPO_SSH" "$TEMP_DIR/repo"
        REPO_DIR="$TEMP_DIR/repo"
    fi

    mkdir -p "$SKILLS_TARGET"
    cp -r "$REPO_DIR/skills/"* "$SKILLS_TARGET/"
    ok "Skills 已安装到 $SKILLS_TARGET"

    if [ -d "$REPO_DIR/tools" ]; then
        mkdir -p "$HOME/.claude/tools"
        cp -r "$REPO_DIR/tools/"* "$HOME/.claude/tools/" 2>/dev/null || true
        ok "Tools 已安装到 $HOME/.claude/tools"
    fi
}

install_from_source() {
    info "从源码编译安装 aris..."

    if ! command -v cargo &>/dev/null; then
        info "安装 Rust 工具链..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    info "克隆 aris-code 分支..."
    git clone -b "$BRANCH_CODE" --depth 50 "$REPO_URL" "$TEMP_DIR/aris-code" 2>/dev/null || \
    git clone -b "$BRANCH_CODE" --depth 50 "$REPO_SSH" "$TEMP_DIR/aris-code"

    info "编译 (release 模式，可能需要几分钟)..."
    cd "$TEMP_DIR/aris-code"
    cargo build --release -p aris-cli

    info "安装二进制..."
    sudo cp "target/release/aris" "$INSTALL_DIR/aris"
    sudo chmod +x "$INSTALL_DIR/aris"

    ok "aris 已安装到 $INSTALL_DIR/aris"
    aris --version 2>/dev/null || true
}

install_from_release() {
    local RELEASE_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/download/${TAG}/aris-linux-x64.tar.gz"
    info "下载预编译二进制 ($TAG)..."

    if curl -fsSL "$RELEASE_URL" -o "$TEMP_DIR/aris.tar.gz" 2>/dev/null; then
        cd "$TEMP_DIR"
        tar xzf aris.tar.gz
        sudo mv aris "$INSTALL_DIR/aris"
        sudo chmod +x "$INSTALL_DIR/aris"
        ok "aris 已安装到 $INSTALL_DIR/aris"
    else
        warn "Release 未找到，回退到源码编译..."
        install_from_source
    fi
}

show_help() {
    cat <<HELP
ARIS 部署脚本 (RobWonn 自定义版本)

用法: bash deploy_aris.sh [选项]

选项:
  --from-source    从源码编译安装 (需要 Rust)
  --skills-only    只安装 skills，不安装 aris 二进制
  --help           显示帮助

无选项时默认: 安装 skills + 尝试从 Release 下载预编译二进制

安装完成后运行:
  aris setup       # 初始化配置 (API key, base URL 等)
  aris             # 进入交互模式
HELP
}

# ---- main ----
MODE="release"
for arg in "$@"; do
    case "$arg" in
        --from-source)  MODE="source" ;;
        --skills-only)  MODE="skills" ;;
        --help|-h)      show_help; exit 0 ;;
        *) err "未知参数: $arg" ;;
    esac
done

echo ""
echo "  ╭──────────────────────────────────────────╮"
echo "  │     ARIS 部署 (RobWonn custom build)     │"
echo "  │     thinking 支持 · pincc.ai 兼容        │"
echo "  ╰──────────────────────────────────────────╯"
echo ""

install_skills

case "$MODE" in
    source)  install_from_source ;;
    release) install_from_release ;;
    skills)  info "跳过二进制安装 (--skills-only)" ;;
esac

echo ""
ok "部署完成！"
echo ""
echo "  下一步:"
echo "    1. aris setup          # 配置 API key 和 base URL"
echo "    2. aris                # 进入交互模式"
echo "    3. /research-lit 题目  # 开始文献调研"
echo ""
