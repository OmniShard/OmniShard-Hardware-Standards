#!/bin/bash

# =================================================================
# OmniShard Hardware Compliance Auditor v1.1
# Author: Nguyễn Ngọc Hùng (OmniShard Architect)
# ĐIỀU KHOẢN: Chỉ dùng để đánh giá hạ tầng mạng OmniShardNet.
# =================================================================

LOG_FILE="omni_audit_$(date +%Y%m%d_%H%M%S).log"
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Khởi tạo file log với thông tin mã hóa
echo "--- OMNISHARD AUDIT RAW DATA ---" > $LOG_FILE
echo "Timestamp: $(date)" >> $LOG_FILE

echo -e "${YELLOW}--- Khởi động tiến trình kiểm tra OmniShard ---${NC}"

log_internal() {
    echo "[DATA] $1: $2" >> $LOG_FILE
}

# 1. Kiểm tra Hệ điều hành
OS=$(uname -s)
KERNEL=$(uname -r)
log_internal "OS" "$OS"
log_internal "Kernel" "$KERNEL"

if [ "$OS" != "Linux" ]; then
    echo -e "${RED}[FAILED]${NC} Yêu cầu Linux. Hệ điều hành hiện tại ($OS) không an toàn."
else
    echo -e "${GREEN}[PASSED]${NC} Hệ điều hành: $OS (Kernel: $KERNEL)"
fi

# 2. Kiểm tra SWAP (Chống lộ mảnh khóa)
SWAP_TOTAL=$(free -m | grep -i swap | awk '{print $2}')
log_internal "Swap_Total" "$SWAP_TOTAL"
if [ "$SWAP_TOTAL" -eq 0 ]; then
    echo -e "${GREEN}[PASSED]${NC} SWAP: Đã tắt (Secure RAM Mode)."
else
    echo -e "${RED}[FAILED]${NC} SWAP đang bật. Nguy cơ rò rỉ dữ liệu mật mã xuống disk!"
fi

# 3. Kiểm tra ảo hóa
VIRT=$(systemd-detect-virt 2>/dev/null || echo "unknown")
log_internal "Virtualization" "$VIRT"
if [ "$VIRT" == "none" ]; then
    echo -e "${GREEN}[PASSED]${NC} Hạ tầng: Bare-metal (Phần cứng thực)."
else
    echo -e "${YELLOW}[WARNING]${NC} Phát hiện ảo hóa ($VIRT). Cần đội ngũ OmniShard phê duyệt thủ công."
fi

# 4. Kiểm tra mã hóa phần cứng (AES-NI)
if grep -q "aes" /proc/cpuinfo; then
    echo -e "${GREEN}[PASSED]${NC} CPU: Hỗ trợ tăng tốc mã hóa phần cứng."
else
    echo -e "${YELLOW}[WARNING]${NC} CPU không hỗ trợ AES-NI. Tốc độ phân mảnh sẽ chậm."
fi

# 5. Kiểm tra RAM
RAM_GB=$(free -g | grep -i mem | awk '{print $2}')
log_internal "RAM_Total_GB" "$RAM_GB"
if [ "$RAM_GB" -lt 15 ]; then
    echo -e "${RED}[FAILED]${NC} RAM: ${RAM_GB}GB (Yêu cầu tối thiểu 16GB)."
else
    echo -e "${GREEN}[PASSED]${NC} RAM: ${RAM_GB}GB."
fi

# 6. Xuất mã Hash ra file riêng và màn hình
echo -e "\n${YELLOW}--- Đang niêm phong báo cáo kỹ thuật... ---${NC}"

# Tạo file chữ ký riêng (.sig)
sha256sum "$LOG_FILE" > "${LOG_FILE}.sig"

# Khóa file log để tránh vô tình sửa đổi trên server
chmod 444 "$LOG_FILE"

echo -e "${GREEN}[Xong]${NC} Báo cáo: ${YELLOW}$LOG_FILE${NC}"
echo -e "${GREEN}[Xong]${NC} File chữ ký: ${YELLOW}${LOG_FILE}.sig${NC}"
echo -e "\n${RED}QUAN TRỌNG:${NC}"
echo -e "Hãy gửi cả 2 file trên cho ${GREEN}Nguyễn Ngọc Hùng${NC}."
echo -e "Hoặc copy mã Hash dưới đây để xác thực nhanh:"
echo -e "${YELLOW}$(cat ${LOG_FILE}.sig | awk '{print $1}')${NC}\n"
