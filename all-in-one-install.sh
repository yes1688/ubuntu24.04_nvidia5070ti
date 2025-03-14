#!/bin/bash
# 整合版腳本：安裝NVIDIA RTX 5070 Ti 驅動、CUDA工具包及設置環境變數
# 適用於Ubuntu 24.04系統

# 工作目錄和進度追踪文件
WORK_DIR="$HOME/.nvidia_install_progress"
mkdir -p "$WORK_DIR"
STAGE_FILE="$WORK_DIR/install_stage"

# 在重啟後確保腳本會自動運行
setup_autostart() {
    SCRIPT_PATH=$(readlink -f "$0")
    AUTOSTART_FILE="$HOME/.config/autostart/nvidia-cuda-install.desktop"

    mkdir -p "$HOME/.config/autostart"
    cat >"$AUTOSTART_FILE" <<EOL
[Desktop Entry]
Type=Application
Name=NVIDIA CUDA Installation
Exec=gnome-terminal -- bash -c "$SCRIPT_PATH; rm $AUTOSTART_FILE"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOL
}

# 檢查當前安裝階段
if [ -f "$STAGE_FILE" ]; then
    STAGE=$(cat "$STAGE_FILE")
else
    STAGE=0
fi

case $STAGE in
0)
    echo "=== 開始NVIDIA驅動和CUDA工具包安裝 ==="

    #==============================================================================
    # 第1步: 更新系統套件
    #==============================================================================
    echo "正在更新系統..."
    sudo apt update && sudo apt upgrade -y

    #==============================================================================
    # 第2步: 禁用Nouveau開源驅動(與NVIDIA專有驅動衝突)
    #==============================================================================
    echo "正在禁用Nouveau驅動..."
    echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
    sudo update-initramfs -u

    # 設置下一階段並配置自動啟動
    echo "1" >"$STAGE_FILE"
    setup_autostart

    echo "系統將在10秒後重啟以繼續安裝..."
    sleep 10
    sudo reboot
    ;;

1)
    #==============================================================================
    # 第3步: 添加NVIDIA驅動PPA並安裝驅動
    #==============================================================================
    echo "正在安裝NVIDIA驅動..."
    sudo add-apt-repository ppa:graphics-drivers/ppa -y
    sudo apt update

    sudo apt install -y nvidia-driver-570-open

    # 設置下一階段並配置自動啟動
    echo "2" >"$STAGE_FILE"
    setup_autostart

    echo "系統將在10秒後重啟以繼續安裝..."
    sleep 10
    sudo reboot
    ;;

2)
    #==============================================================================
    # 第4步: 驗證NVIDIA驅動安裝
    #==============================================================================
    echo "驗證NVIDIA驅動安裝..."
    if ! command -v nvidia-smi &>/dev/null; then
        echo "NVIDIA驅動未正確安裝，腳本將退出"
        exit 1
    fi

    echo "NVIDIA驅動已成功安裝:"
    nvidia-smi

    #==============================================================================
    # 第5步: 安裝CUDA工具包
    #==============================================================================
    echo "正在安裝CUDA工具包..."

    # 下載CUDA存儲庫配置
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
    sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600

    # 下載並安裝CUDA存儲庫包
    wget https://developer.download.nvidia.com/compute/cuda/12.8.1/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.1-570.124.06-1_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu2404-12-8-local_12.8.1-570.124.06-1_amd64.deb
    sudo cp /var/cuda-repo-ubuntu2404-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/

    # 更新並安裝CUDA工具包
    sudo apt-get update
    sudo apt-get -y install cuda-toolkit-12-8

    echo "CUDA工具包安裝完成"

    #==============================================================================
    # 第6步: 設置CUDA環境變數
    #==============================================================================
    # 確定用戶使用的shell配置文件
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    else
        SHELL_CONFIG="$HOME/.profile"
    fi

    echo "正在設置CUDA環境變數..."

    # 檢查是否已經添加過環境變數
    if grep -q "CUDA_HOME" "$SHELL_CONFIG"; then
        echo "CUDA環境變數已經存在於 $SHELL_CONFIG 中"
    else
        # 添加CUDA環境變數到shell配置文件
        echo "" >>"$SHELL_CONFIG"
        echo "# CUDA環境變數" >>"$SHELL_CONFIG"
        echo "export CUDA_HOME=/usr/local/cuda-12.8" >>"$SHELL_CONFIG"
        echo "export PATH=\$CUDA_HOME/bin:\$PATH" >>"$SHELL_CONFIG"
        echo "export LD_LIBRARY_PATH=\$CUDA_HOME/lib64:\$LD_LIBRARY_PATH" >>"$SHELL_CONFIG"

        echo "CUDA環境變數已添加到 $SHELL_CONFIG"
    fi

    # 清理安裝過程中的臨時文件
    echo "正在清理安裝文件..."
    rm -f cuda-repo-ubuntu2404-12-8-local_12.8.1-570.124.06-1_amd64.deb

    # 刪除進度文件
    rm -f "$STAGE_FILE"

    echo ""
    echo "=== 安裝完成! ==="
    echo "NVIDIA驅動和CUDA工具包已成功安裝"
    echo ""
    echo "請運行以下命令使環境變數立即生效:"
    echo "source $SHELL_CONFIG"
    echo ""
    echo "然後使用以下命令驗證CUDA安裝:"
    echo "nvcc --version"
    ;;

*)
    echo "未知的安裝階段: $STAGE"
    exit 1
    ;;
esac
