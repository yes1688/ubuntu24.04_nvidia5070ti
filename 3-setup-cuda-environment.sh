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
echo "嘗試在當前終端生效環境變數..."
source "$SHELL_CONFIG" 2>/dev/null || true

# 驗證CUDA安裝
echo "驗證CUDA工具包安裝:"
if command -v nvcc &>/dev/null; then
    nvcc --version
    echo "CUDA環境在當前終端設置成功!"
else
    echo "注意: nvcc命令在當前終端無法使用。"
    echo "這可能是因為環境變數尚未在所有終端會話中生效。"
fi

echo ""
echo "⚠️  重要提示 ⚠️"
echo "環境變數已添加到 $SHELL_CONFIG，但可能需要以下操作才能完全生效:"
echo "1. 重新開啟終端機"
echo "2. 登出後再重新登入"
echo "3. 或手動執行: source $SHELL_CONFIG"
echo ""
echo "完整生效後，您可以在任何終端中使用 'nvcc --version' 驗證安裝"
