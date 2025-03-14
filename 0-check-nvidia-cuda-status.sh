#!/bin/bash
# 檢查NVIDIA驅動和CUDA狀態的腳本
# 適用於Ubuntu 24.04系統

echo "=== NVIDIA和CUDA安裝狀態檢查 ==="
echo ""

#==============================================================================
# 檢查NVIDIA驅動安裝狀態
#==============================================================================
echo "檢查NVIDIA驅動..."
if command -v nvidia-smi &>/dev/null; then
    echo "✅ NVIDIA驅動已安裝："
    nvidia-smi | head -n 10
    DRIVER_INSTALLED=true
else
    echo "❌ NVIDIA驅動未安裝或未正確配置"
    DRIVER_INSTALLED=false
fi
echo ""

#==============================================================================
# 檢查CUDA安裝狀態
#==============================================================================
echo "檢查CUDA工具包..."

# 檢查CUDA目錄
CUDA_DIRS=(/usr/local/cuda* /opt/cuda*)
CUDA_FOUND=false
CUDA_PATH=""

for dir in "${CUDA_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ 找到CUDA目錄: $dir"
        CUDA_FOUND=true
        CUDA_PATH=$dir
        break
    fi
done

if [ "$CUDA_FOUND" = false ]; then
    echo "❌ 未找到CUDA安裝目錄"
fi

# 檢查nvcc命令
if command -v nvcc &>/dev/null; then
    echo "✅ CUDA nvcc編譯器可用："
    nvcc --version
    NVCC_AVAILABLE=true
else
    echo "❌ CUDA nvcc編譯器未找到或未正確配置"
    NVCC_AVAILABLE=false
fi
echo ""

#==============================================================================
# 檢查環境變數設置
#==============================================================================
echo "檢查CUDA環境變數..."

# 確定使用的shell配置文件
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    SHELL_CONFIG="$HOME/.profile"
fi

if grep -q "CUDA_HOME\|LD_LIBRARY_PATH.*cuda" "$SHELL_CONFIG"; then
    echo "✅ CUDA環境變數已在 $SHELL_CONFIG 中設置"
    ENV_VARS_SET=true
else
    echo "❌ CUDA環境變數未在 $SHELL_CONFIG 中設置"
    ENV_VARS_SET=false
fi
echo ""

#==============================================================================
# 結論與建議
#==============================================================================
echo "=== 診斷結果與建議 ==="

if [ "$DRIVER_INSTALLED" = true ] && [ "$CUDA_FOUND" = true ] && [ "$NVCC_AVAILABLE" = true ]; then
    echo "✅ 您的系統已正確設置NVIDIA驅動和CUDA工具包，無需進一步操作。"
elif [ "$DRIVER_INSTALLED" = true ] && [ "$CUDA_FOUND" = true ] && [ "$NVCC_AVAILABLE" = false ]; then
    echo "⚠️  NVIDIA驅動和CUDA已安裝，但環境變數未正確設置。"
    echo "建議執行: ./3-setup-cuda-environment.sh"

    if [ -n "$CUDA_PATH" ]; then
        echo ""
        echo "或手動添加以下內容到 $SHELL_CONFIG："
        echo "export CUDA_HOME=$CUDA_PATH"
        echo "export PATH=\$CUDA_HOME/bin:\$PATH"
        echo "export LD_LIBRARY_PATH=\$CUDA_HOME/lib64:\$LD_LIBRARY_PATH"
    fi
elif [ "$DRIVER_INSTALLED" = true ] && [ "$CUDA_FOUND" = false ]; then
    echo "⚠️  NVIDIA驅動已安裝，但未找到CUDA工具包。"
    echo "建議執行: ./2-install-cuda-toolkit.sh"
elif [ "$DRIVER_INSTALLED" = false ]; then
    echo "⚠️  NVIDIA驅動未安裝或未正確配置。"
    echo "建議執行: ./1-install-nvidia-driver-5070ti.sh"
    echo "或完整安裝: ./all-in-one-install.sh"
fi
echo ""

# 顯示系統詳細資訊
echo "=== 系統詳細資訊 ==="
echo "Ubuntu版本:"
lsb_release -a 2>/dev/null | grep Description
echo ""
echo "內核版本:"
uname -r
echo ""
echo "GPU資訊:"
if [ "$DRIVER_INSTALLED" = true ]; then
    lspci | grep -i nvidia
fi
