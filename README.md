# 🖥️ NVIDIA RTX 5070 Ti 驅動和CUDA安裝指南

這個項目提供一系列腳本，幫助您在Ubuntu 24.04系統上輕鬆安裝和配置NVIDIA RTX 5070 Ti驅動和CUDA工具包。無論您是機器學習研究者、遊戲開發者還是需要GPU運算能力的用戶，這些腳本都可以幫助您快速配置環境。

## 📋 系統需求

- Ubuntu 24.04 操作系統
- NVIDIA RTX 5070 Ti 顯卡（其他NVIDIA顯卡也可能適用，但未經完整測試）
- 管理員權限（sudo）
- 穩定的網絡連接（用於下載驅動和CUDA）
- 至少20GB的可用磁盤空間（用於CUDA工具包）

## 🛠️ 安裝腳本

| 腳本名稱                            | 功能                           | 運行時間              |
| ----------------------------------- | ------------------------------ | --------------------- |
| `0-check-nvidia-cuda-status.sh`     | 檢查系統狀態                   | <1分鐘                |
| `1-install-nvidia-driver-5070ti.sh` | 安裝NVIDIA驅動                 | ~10分鐘（含兩次重啟） |
| `2-install-cuda-toolkit.sh`         | 安裝CUDA工具包                 | ~15-20分鐘            |
| `3-setup-cuda-environment.sh`       | 設置CUDA環境變數               | <1分鐘                |
| `all-in-one-install.sh`             | 一體化安裝（包含以上所有步驟） | ~30分鐘               |

### 📊 腳本詳細說明

#### 0️⃣ 檢查當前系統狀態
```bash
./0-check-nvidia-cuda-status.sh
```
🔍 **功能**：診斷您的系統，檢查NVIDIA驅動和CUDA的安裝狀態，並給出具體的後續步驟建議。
💡 **提示**：使用此腳本可以避免重複安裝和排除故障。

#### 1️⃣ 安裝NVIDIA驅動
```bash
./1-install-nvidia-driver-5070ti.sh
```
🔍 **功能**：安裝NVIDIA RTX 5070 Ti專用驅動程式。
⚠️ **注意**：此腳本將重啟您的系統**兩次**：
   - 第一次：禁用Nouveau開源驅動後
   - 第二次：安裝NVIDIA專有驅動後
💡 **提示**：重啟後需要再次手動執行腳本繼續安裝。

#### 2️⃣ 安裝CUDA工具包
```bash
./2-install-cuda-toolkit.sh
```
🔍 **功能**：安裝CUDA 12.8工具包，包括編譯器、庫和開發工具。
⚠️ **注意**：需要先安裝NVIDIA驅動。
💾 **下載大小**：約4-6GB，安裝後佔用約15GB空間。

#### 3️⃣ 設置CUDA環境變數
```bash
./3-setup-cuda-environment.sh
```
🔍 **功能**：配置必要的環境變數（PATH、LD_LIBRARY_PATH等），使系統能夠找到CUDA工具。
⚠️ **重要提示**：環境變數設定後需要**重新開啟終端機**或**重新登入**才能完全生效。
✅ **成果**：正確生效後，您可以在任何終端使用`nvcc`等CUDA命令。

#### 🔄 一體化安裝腳本
```bash
./all-in-one-install.sh
```
🔍 **功能**：自動執行完整的安裝流程，包括所有重啟和環境配置。
💡 **優點**：會自動在重啟後繼續執行，無需手動干預。

## 📝 推薦安裝流程

### 快速診斷方式
1. 首先運行：`./0-check-nvidia-cuda-status.sh`
2. 按照診斷結果的建議執行相應腳本

### 📊 根據需求選擇
- **新系統完整安裝**：`./all-in-one-install.sh`
- **僅需驅動**：`./1-install-nvidia-driver-5070ti.sh`
- **已有驅動，需要CUDA**：`./2-install-cuda-toolkit.sh` 然後 `./3-setup-cuda-environment.sh`
- **僅設置環境變數**：`./3-setup-cuda-environment.sh`

### 🔢 按步驟安裝（最穩定方式）
按順序逐一執行腳本: 0 → 1 → 2 → 3

## ✅ 驗證安裝

安裝完成後，您可以使用以下命令驗證：

- **檢查NVIDIA驅動**：
```bash
nvidia-smi
```
預期輸出示例：
```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 570.xx       Driver Version: 570.xx       CUDA Version: 12.8     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0  On |                  N/A |
|  0%   45C    P8    12W / 200W |    123MiB / 16384MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
```

- **檢查CUDA工具包**：
```bash
nvcc --version
```
預期輸出示例：
```
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2023 NVIDIA Corporation
Built on Sat_Sep_16_17:17:28_PDT_2023
Cuda compilation tools, release 12.8, V12.8.x
```

## ❓ 常見問題與故障排除

1. **執行腳本時顯示"Permission denied"**
   ```bash
   chmod +x *.sh  # 為所有腳本添加執行權限
   ```

2. **重啟後腳本沒有繼續執行**
   - 對於分步驅動安裝，您需要在重啟後手動再次運行腳本
   - 使用`all-in-one-install.sh`可自動在重啟後繼續

3. **安裝驅動後黑屏或圖形界面問題**
   - 使用Ctrl+Alt+F3進入終端模式
   - 運行`sudo apt remove --purge nvidia-*`移除驅動
   - 然後運行`sudo ubuntu-drivers autoinstall`嘗試自動安裝適合的驅動

4. **CUDA命令無法使用**
   - 環境變數設定後需要重新開啟終端機或重新登入系統
   - 手動使環境變數生效：`source ~/.bashrc` (或您的shell配置文件)
   - 檢查CUDA路徑：`echo $PATH`應包含CUDA路徑
   - 如果上述方法都不起作用，嘗試系統重啟

## 📚 更多資源

- [NVIDIA官方驅動下載](https://www.nvidia.com/download/index.aspx)
- [CUDA工具包文檔](https://docs.nvidia.com/cuda/)
- [Ubuntu NVIDIA驅動指南](https://help.ubuntu.com/community/NvidiaDriversInstallation)

---

⭐ 如果這些腳本幫助到您，歡迎給項目點贊！
