#!/bin/bash
# 安裝NVIDIA RTX 5070 Ti 驅動的腳本
# 適用於Ubuntu 24.04系統

#==============================================================================
# 第1步: 更新系統套件
#==============================================================================
sudo apt update && sudo apt upgrade -y

#==============================================================================
# 第2步: 禁用Nouveau開源驅動(與NVIDIA專有驅動衝突)
#==============================================================================
echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
sudo update-initramfs -u

# 重啟系統以應用更改
echo "系統將重啟以禁用Nouveau驅動"
echo "請在重啟後再次執行此腳本繼續安裝"
echo "按Enter鍵繼續..."
read
sudo reboot

#==============================================================================
# 第3步: 添加NVIDIA驅動PPA並安裝驅動
#==============================================================================
# 添加NVIDIA驅動的PPA源
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update

# 安裝NVIDIA驅動570版本(開源版本)
sudo apt install nvidia-driver-570-open

# 重啟以完成驅動安裝
echo "驅動安裝完成，系統將重啟以啟用NVIDIA驅動"
echo "按Enter鍵繼續..."
read
sudo reboot

#==============================================================================
# 第4步: 驗證NVIDIA驅動安裝
#==============================================================================
# 運行此命令確認驅動已正確安裝
echo "驗證NVIDIA驅動是否成功安裝:"
nvidia-smi

echo ""
echo "NVIDIA驅動安裝完成!"
echo "如果您需要安裝CUDA工具包，請運行: ./2-install-cuda-toolkit.sh"
