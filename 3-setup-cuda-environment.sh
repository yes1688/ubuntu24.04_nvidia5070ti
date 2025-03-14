#!/bin/bash
# 設置CUDA環境變數的腳本
# 適用於Ubuntu 24.04系統

# 確定用戶使用的shell配置文件
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    SHELL_CONFIG="$HOME/.profile"
fi

echo "正在將CUDA環境變數添加到 $SHELL_CONFIG..."

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

# 使環境變數立即生效
echo "正在使環境變數生效..."
source "$SHELL_CONFIG"

# 驗證CUDA安裝
echo "驗證CUDA工具包安裝:"
if command -v nvcc &>/dev/null; then
    nvcc --version
    echo "CUDA環境設置成功!"
else
    echo "警告: nvcc命令仍無法使用。"
    echo "請確認CUDA工具包已正確安裝，路徑是否為 /usr/local/cuda-12.8"
    echo "如果路徑不同，請編輯腳本並修改CUDA_HOME變數。"
fi

echo ""
echo "您也可以手動運行以下命令使環境變數立即生效:"
echo "source $SHELL_CONFIG"
