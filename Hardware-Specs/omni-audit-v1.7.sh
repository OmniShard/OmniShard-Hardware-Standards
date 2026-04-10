#!/bin/bash
# =================================================================
# OmniShard Hardware Compliance Auditor v1.7
# Author: Nguyễn Ngọc Hùng (OmniShard Architect)
# 
# CHANGELOG v1.7:
#   - Khôi phục kiểm tra SWAP (từ v1.5)
#   - Khôi phục kiểm tra ảo hóa Bare-metal (từ v1.5)
#   - Giữ nguyên các kiểm tra nâng cao: CPU, TPM, Secure Boot, ECC (từ v1.6)
#   - Bổ sung kiểm tra sự tồn tại của lệnh trước khi dùng
#   - Thêm tùy chọn --verify để xác thực báo cáo
#   - Gắn serial number mainboard để chống clone
#
# ĐIỀU KHOẢN: Chỉ dùng để đánh giá hạ tầng mạng OmniShardNet.
# =================================================================

VERSION="1.7"
LOG_FILE="omni_audit_$(hostname)_$(date +%Y%m%d_%H%M%S).log"
PRI_KEY="/etc/omnishard/node_private.pem"
PUB_KEY="/etc/omnishard/node_public.pem"

# Màu sắc terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# =================================================================
# Hàm ghi log song song (vừa in màn hình vừa ghi file)
# =================================================================
log_message() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# =================================================================
# Hàm kiểm tra sự tồn tại của lệnh
# =================================================================
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log_message "${YELLOW}[WARN]${NC} Lệnh '$1' không có sẵn, bỏ qua kiểm tra liên quan."
        return 1
    fi
    return 0
}

# =================================================================
# Hàm hiển thị usage
# =================================================================
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --verify <log_file> <sig_file> [pub_key]  Xác thực báo cáo đã ký"
    echo "  --help                                    Hiển thị trợ giúp"
    echo ""
    echo "Chạy không tham số: Thực hiện kiểm tra toàn bộ phần cứng"
}

# =================================================================
# Hàm xác thực chữ ký (chế độ --verify)
# =================================================================
verify_report() {
    local LOG="$1"
    local SIG="$2"
    local KEY="${3:-$PUB_KEY}"
    
    if [ ! -f "$LOG" ]; then
        echo -e "${RED}[ERROR]${NC} Không tìm thấy file log: $LOG"
        return 1
    fi
    
    if [ ! -f "$SIG" ]; then
        echo -e "${RED}[ERROR]${NC} Không tìm thấy file chữ ký: $SIG"
        return 1
    fi
    
    if [ ! -f "$KEY" ]; then
        echo -e "${RED}[ERROR]${NC} Không tìm thấy public key: $KEY"
        echo -e "${YELLOW}[INFO]${NC} Sử dụng: $0 --verify <log> <sig> <public_key>"
        return 1
    fi
    
    if ! command -v openssl >/dev/null 2>&1; then
        echo -e "${RED}[ERROR]${NC} Thiếu OpenSSL, không thể xác thực"
        return 1
    fi
    
    echo -e "${YELLOW}--- Xác thực báo cáo OmniShard v$VERSION ---${NC}"
    openssl dgst -sha256 -verify "$KEY" -signature "$SIG" "$LOG"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Chữ ký hợp lệ! Báo cáo chưa bị sửa đổi."
        return 0
    else
        echo -e "${RED}[FAILED]${NC} Chữ ký không hợp lệ! Báo cáo đã bị can thiệp."
        return 1
    fi
}

# =================================================================
# Xử lý tham số dòng lệnh
# =================================================================
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    show_usage
    exit 0
fi

if [ "$1" == "--verify" ]; then
    if [ $# -lt 3 ]; then
        echo -e "${RED}[ERROR]${NC} Thiếu tham số cho --verify"
        show_usage
        exit 1
    fi
    verify_report "$2" "$3" "$4"
    exit $?
fi

# =================================================================
# 0. Kiểm tra quyền Root & OpenSSL
# =================================================================
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} Vui lòng chạy bằng sudo (cần quyền Root để đọc thông tin phần cứng)."
    exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
    echo -e "${RED}[ERROR]${NC} Thiếu OpenSSL. Vui lòng cài đặt: apt install openssl / yum install openssl"
    exit 1
fi

# =================================================================
# Tạo file log header
# =================================================================
{
echo "--- OMNISHARD FULL AUDIT REPORT V$VERSION ---"
echo "Node_Hostname: $(hostname)"
echo "Node_IP: $(hostname -I 2>/dev/null | awk '{print $1}')"
echo "Timestamp: $(date -Iseconds)"
echo "System_Serial: $(dmidecode -s system-serial-number 2>/dev/null || echo "Unknown")"
echo "---------------------------------------------"
} > "$LOG_FILE"

log_message "${YELLOW}--- Khởi động kiểm tra hạ tầng OmniShard v$VERSION ---${NC}"

# =================================================================
# 1. Kiểm tra Hệ điều hành & Kernel
# =================================================================
OS=$(uname -s)
KERNEL=$(uname -r)
if [ "$OS" = "Linux" ]; then
    log_message "${GREEN}[PASSED]${NC} OS: $OS (Kernel: $KERNEL)"
else
    log_message "${RED}[FAILED]${NC} OS: $OS (Yêu cầu Linux)"
fi

# =================================================================
# 2. Kiểm tra Ảo hóa (Bare-metal requirement)
# =================================================================

echo "========== KIỂM TRA MÔI TRƯỜNG CHẠY =========="

# 1. systemd-detect-virt
if command -v systemd-detect-virt >/dev/null 2>&1; then
    VIRT=$(systemd-detect-virt 2>/dev/null)
    if [ -z "$VIRT" ]; then
        VIRT="none"
    fi
else
    VIRT="unknown"
fi
echo "[1] systemd-detect-virt: $VIRT"

# 2. DMI
MANU=$(sudo dmidecode -s system-manufacturer 2>/dev/null || echo "không đọc được")
PROD=$(sudo dmidecode -s system-product-name 2>/dev/null || echo "không đọc được")
echo "[2] Nhà sản xuất: $MANU"
echo "[3] Model: $PROD"

# 3. CPU hỗ trợ
if grep -q "vmx" /proc/cpuinfo 2>/dev/null; then
    echo "[4] CPU hỗ trợ: Intel VT-x (CÓ)"
elif grep -q "svm" /proc/cpuinfo 2>/dev/null; then
    echo "[4] CPU hỗ trợ: AMD-V (CÓ)"
else
    echo "[4] CPU hỗ trợ: KHÔNG"
fi

# 4. KVM
if [ -e "/dev/kvm" ]; then
    echo "[5] KVM: ĐANG HOẠT ĐỘNG (có /dev/kvm)"
else
    echo "[5] KVM: KHÔNG hoạt động"
fi

# 5. Process hypervisor (thêm "then" vào đây)
if ps aux | grep -E "qemu|libvirt|vbox|vmware" | grep -v grep > /dev/null; then
    echo "[6] Hypervisor process: ĐANG CHẠY"
else
    echo "[6] Hypervisor process: KHÔNG"
fi

# ========= KẾT LUẬN (sửa logic) ==========
echo "========== KẾT LUẬN =========="

# SỬA: Kiểm tra từ cụ thể nhất đến tổng quát nhất
if [ "$VIRT" != "none" ] && [ "$VIRT" != "unknown" ]; then
    echo "❌ ĐANG CHẠY TRONG MÁY ẢO ($VIRT)"
    echo "   => KHÔNG đạt yêu cầu Bare-metal!"
elif [ -e "/dev/kvm" ]; then
    echo "⚠️ BARE-METAL NHƯNG ĐANG CHẠY KVM (hypervisor đang hoạt động)"
    echo "   => KHÔNG đạt yêu cầu! Tắt KVM nếu muốn đạt chuẩn."
elif [ "$VIRT" = "none" ]; then
    echo "✅ BARE-METAL (Thiết bị thật, không ảo hóa)"
    echo "   => ĐẠT yêu cầu OmniShard!"
else
    echo "⚠️ KHÔNG XÁC ĐỊNH ĐƯỢC (thiếu systemd-detect-virt)"
fi


# =================================================================
# 3. Kiểm tra SWAP (Chống rò rỉ Key - yêu cầu bắt buộc)
# =================================================================
SWAP_TOTAL=$(free -m | awk '/^Swap:/{print $2}')
if [ -z "$SWAP_TOTAL" ] || [ "$SWAP_TOTAL" -eq 0 ]; then
    log_message "${GREEN}[PASSED]${NC} SWAP: Đã tắt (Secure RAM Mode)."
else
    log_message "${RED}[FAILED]${NC} SWAP đang bật ($SWAP_TOTAL MB). Nguy cơ rò rỉ Key! Tắt swap bằng 'swapoff -a'."
fi

# =================================================================
# 4. Kiểm tra RAM VẬT LÝ (chính xác từ phần cứng)
# =================================================================

# Lấy RAM vật lý tổng từ dmidecode (đơn vị MB)
if command -v dmidecode >/dev/null 2>&1; then
    RAM_HARDWARE_MB=$(sudo dmidecode -t memory 2>/dev/null | grep -E "Size:" | grep -v "No Module" | awk '{sum+=$2} END {print sum}')
    
    # Nếu dmidecode không ra kết quả, fallback sang MemTotal
    if [ -z "$RAM_HARDWARE_MB" ] || [ "$RAM_HARDWARE_MB" -eq 0 ]; then
        RAM_HARDWARE_MB=$(grep MemTotal /proc/meminfo | awk '{print $2 / 1024}')
        log_message "${YELLOW}[WARN]${NC} Không đọc được RAM từ dmidecode, dùng MemTotal (không chính xác tuyệt đối)"
    fi
else
    RAM_HARDWARE_MB=$(grep MemTotal /proc/meminfo | awk '{print $2 / 1024}')
    log_message "${YELLOW}[WARN]${NC} Thiếu dmidecode, dùng MemTotal (không chính xác tuyệt đối)"
fi

# So sánh với ngưỡng 16GB (16384 MB)
if [ "${RAM_HARDWARE_MB%.*}" -lt 16000 ]; then
    log_message "${RED}[FAILED]${NC} RAM vật lý: ${RAM_HARDWARE_MB%.*} MB (Yêu cầu tối thiểu 16384 MB)"
else
    log_message "${GREEN}[PASSED]${NC} RAM vật lý: ${RAM_HARDWARE_MB%.*} MB (Đạt yêu cầu 16GB)"
fi
# =================================================================
# 5. Kiểm tra CPU (Cores, AES-NI, SGX)
# =================================================================
CORES=$(nproc)
log_message "CPU Cores: $CORES"

if grep -qi "aes" /proc/cpuinfo; then
    log_message "${GREEN}[PASSED]${NC} AES-NI: Hỗ trợ (tăng tốc mã hóa)."
else
    log_message "${RED}[FAILED]${NC} AES-NI: Không hỗ trợ! Hiệu năng mã hóa sẽ bị ảnh hưởng."
fi

if grep -qi "sgx" /proc/cpuinfo; then
    log_message "${GREEN}[PASSED]${NC} Intel SGX: Hỗ trợ (Enclave an toàn)."
else
    log_message "${YELLOW}[WARN]${NC} Intel SGX: Không phát hiện (không bắt buộc)."
fi

# =================================================================
# 6. Kiểm tra ECC RAM
# =================================================================
if check_command dmidecode; then
    ECC_CHECK=$(dmidecode -t memory 2>/dev/null | grep -i "Error Correction Type" | grep -vi "None" | head -1)
    if [ -n "$ECC_CHECK" ]; then
        log_message "${GREEN}[PASSED]${NC} ECC RAM: Phát hiện ($ECC_CHECK)."
    else
        log_message "${YELLOW}[WARN]${NC} ECC RAM: Không phát hiện hoặc không hỗ trợ (không bắt buộc)."
    fi
fi

# =================================================================
# 7. Kiểm tra TPM 2.0
# =================================================================
if [ -c "/dev/tpm0" ] || [ -c "/dev/tpmrm0" ]; then
    log_message "${GREEN}[PASSED]${NC} TPM 2.0: Đã kích hoạt."
else
    log_message "${RED}[FAILED]${NC} TPM 2.0: Không tìm thấy thiết bị! Yêu cầu bảo mật cao."
fi

# =================================================================
# 8. Kiểm tra Secure Boot
# =================================================================
SB_CHECKED=false
if check_command mokutil; then
    if mokutil --sb-state 2>/dev/null | grep -qi "enabled"; then
        log_message "${GREEN}[PASSED]${NC} Secure Boot: Enabled."
        SB_CHECKED=true
    elif mokutil --sb-state 2>/dev/null | grep -qi "disabled"; then
        log_message "${RED}[FAILED]${NC} Secure Boot: Disabled!"
        SB_CHECKED=true
    fi
fi

if [ "$SB_CHECKED" = false ] && [ -f "/sys/firmware/efi/secure_boot" ]; then
    if [ "$(cat /sys/firmware/efi/secure_boot 2>/dev/null)" = "1" ]; then
        log_message "${GREEN}[PASSED]${NC} Secure Boot: Enabled (via sysfs)."
        SB_CHECKED=true
    fi
fi

if [ "$SB_CHECKED" = false ]; then
    log_message "${YELLOW}[WARN]${NC} Secure Boot: Không thể kiểm tra (thiếu mokutil hoặc EFI vars)."
fi

# =================================================================
# 9. Kiểm tra LSM (SELinux/AppArmor)
# =================================================================
if [ -f "/sys/kernel/security/lsm" ]; then
    LSM=$(cat /sys/kernel/security/lsm 2>/dev/null)
    log_message "Active LSM: $LSM"
    if echo "$LSM" | grep -qi "selinux"; then
        log_message "${GREEN}[PASSED]${NC} SELinux: Đang hoạt động."
    elif echo "$LSM" | grep -qi "apparmor"; then
        log_message "${GREEN}[PASSED]${NC} AppArmor: Đang hoạt động."
    else
        log_message "${YELLOW}[WARN]${NC} Không phát hiện SELinux/AppArmor."
    fi
fi

# =================================================================
# 10. Kiểm tra System Health (Uptime, Nhiệt độ)
# =================================================================
UPTIME=$(uptime -p 2>/dev/null || uptime)
log_message "Uptime: $UPTIME"

if check_command sensors; then
    TEMP=$(sensors 2>/dev/null | grep -E "Package id 0|Tctl|CPU Temp" | head -1 | awk '{print $4}')
    if [ -n "$TEMP" ]; then
        log_message "CPU Temp: $TEMP"
    fi
fi

# =================================================================
# 11. NIÊM PHONG (RSA Digital Signature) - ĐÚNG THỨ TỰ
# =================================================================
log_message "${YELLOW}--- Đang tạo chữ ký số RSA ---${NC}"

if [ -f "$PRI_KEY" ]; then
    # Ghi mốc kết thúc dữ liệu
    echo "--- END OF DATA ---" >> "$LOG_FILE"
    
    # Ký trên file tĩnh, lưu signature ra file RIÊNG BIỆT
    openssl dgst -sha256 -sign "$PRI_KEY" -out "${LOG_FILE}.sig" "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        log_message "${GREEN}[SUCCESS]${NC} Đã niêm phong bằng Private Key."
        
        # Tự động xuất Public Key kèm theo (nếu có thể)
        if [ -f "$PUB_KEY" ]; then
            cp "$PUB_KEY" "${LOG_FILE}.pub"
            log_message "${GREEN}[INFO]${NC} Đã sao chép Public Key kèm theo."
        else
            openssl rsa -in "$PRI_KEY" -pubout -out "${LOG_FILE}.pub" 2>/dev/null
            if [ $? -eq 0 ]; then
                log_message "${GREEN}[INFO]${NC} Đã xuất Public Key từ Private Key."
            fi
        fi
    else
        log_message "${RED}[ERROR]${NC} Ký số thất bại!"
        exit 1
    fi
else
    log_message "${RED}[ERROR]${NC} Không tìm thấy Private Key tại $PRI_KEY."
    log_message "${YELLOW}[INFO]${NC} Tạo key pair bằng: openssl genrsa -out $PRI_KEY 2048"
    exit 1
fi

# =================================================================
# 12. Thiết lập quyền chỉ đọc cho file báo cáo
# =================================================================
chmod 400 "$LOG_FILE" "${LOG_FILE}.sig" "${LOG_FILE}.pub" 2>/dev/null

# =================================================================
# Kết thúc
# =================================================================
log_message "${GREEN}========================================${NC}"
log_message "${GREEN}[XONG]${NC} Báo cáo: ${YELLOW}$LOG_FILE${NC}"
log_message "${GREEN}[XONG]${NC} Chữ ký: ${YELLOW}${LOG_FILE}.sig${NC}"
log_message "${GREEN}[XONG]${NC} Public key: ${YELLOW}${LOG_FILE}.pub${NC}"
log_message "${GREEN}========================================${NC}"
log_message "${YELLOW}Hướng dẫn xác thực báo cáo:${NC}"
log_message "  $0 --verify $LOG_FILE ${LOG_FILE}.sig ${LOG_FILE}.pub"