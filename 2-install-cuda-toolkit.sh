#!/bin/bash
# 安裝CUDA工具包的腳本
# 適用於Ubuntu 24.04系統

#==============================================================================
# 第1步: 驗證NVIDIA驅動是否已安裝
#==============================================================================
if ! command -v nvidia-smi &>/dev/null; then
    echo "錯誤: NVIDIA驅動未安裝或未正確配置"
    echo "請先運行: ./1-install-nvidia-driver-5070ti.sh"
    exit 1
fi

echo "已檢測到NVIDIA驅動:"
nvidia-smi | head -n 3
echo ""

#==============================================================================
# 第2步: 安裝CUDA工具包
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

# 清理安裝過程中的臨時文件
echo "清理安裝文件..."
rm -f cuda-repo-ubuntu2404-12-8-local_12.8.1-570.124.06-1_amd64.deb

#==============================================================================
# 第3步: 提示設置環境變數
#==============================================================================
echo ""
echo "CUDA工具包安裝完成!"
echo "您需要設置CUDA環境變數才能使用CUDA工具"
echo "請運行: ./3-setup-cuda-environment.sh"
