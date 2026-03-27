Chi Tiết Cấu Hình Hệ Điều Hành & Phần Cứng (OS & Hardware Specs)
OmniShard yêu cầu một môi trường hệ điều hành được thắt chặt để đảm bảo các mảnh khóa mật mã không bị rò rỉ qua các lỗ hổng hệ thống.

**⚠️ CẢNH BÁO QUAN TRỌNG:**  Vui lòng đọc kỹ tránh trường hợp cấu hình nhầm, trong trường hợp cần thiết đội ngũ OmniShard sẽ thực hiện đánh giá và tư vấn giải pháp.

1. Hệ điều hành được hỗ trợ (Supported OS)
Các đối tác liên minh chỉ được phép sử dụng các bản phân phối Linux ổn định sau:

A. Ubuntu 22.04 LTS (Jammy Jellyfish) - Khuyên dùng
Kernel: 5.15 hoặc cao hơn.

Ưu điểm: Tương thích tốt nhất với các Docker image của Hyperledger Fabric và bộ thư viện mật mã của OmniShard.

B. Red Hat Enterprise Linux (RHEL) 9.x / Rocky Linux 9.x
Kernel: 5.14 hoặc cao hơn.

Ưu điểm: Phù hợp cho các hệ thống Ngân hàng và Cơ quan nhà nước yêu cầu tính bảo mật và hỗ trợ thương mại cao.

2. Cấu hình phần cứng cụ thể theo vai trò (Role-based Specs)
Trong mô hình Omni-Sharding, mỗi loại Node có một trọng trách riêng:

🛡️ Nút Thành Viên (Peer Node) - Giữ 1 mảnh khóa
CPU: 8 vCPUs (Hỗ trợ Intel SGX là một lợi thế để chạy Enclave giải mã).

RAM: 16GB ECC (Tối thiểu).

Disk: 500GB NVMe SSD (Yêu cầu tốc độ đọc/ghi ngẫu nhiên > 50k IOPS).

HSM: Phải có module bảo mật (vật lý hoặc Cloud) để lưu trữ Private Key của Peer.

⚖️ Nút Điều Phối (Orderer Node) - Xương sống hệ thống
CPU: 16 vCPUs.

RAM: 32GB ECC.

Disk: 1TB NVMe SSD (Cấu hình RAID 10 để chống lỗi vật lý).

Network: Kết nối trực tiếp (Dedicated) tới các Peer Node khác trong liên minh để đảm bảo độ trễ đồng thuận cực thấp.

3. Thiết lập hệ thống bắt buộc (Mandatory System Hardening)
Trước khi cài đặt OmniShard, quản trị viên của đối tác phải thực hiện:

Vô hiệu hóa Swap: sudo swapoff -a (Để ngăn chặn việc mảnh khóa bị ghi tạm thời xuống ổ cứng dưới dạng bản rõ).

Mã hóa phân vùng dữ liệu: Toàn bộ thư mục chứa Ledger của Blockchain phải được mã hóa bằng LUKS (Linux Unified Key Setup).

Giới hạn quyền User: Chỉ cho phép User định danh chạy dịch vụ Docker/Fabric, không chạy dưới quyền root trực tiếp.

Firewall (UFW/Firewalld):

Allow port 7051, 7053 (Peer Communication).

Allow port 9443 (Operations API - Chỉ dành cho Admin).

Deny tất cả các cổng còn lại.

4. Kiểm tra sự tuân thủ (Compliance Check)
Mỗi Node khi khởi tạo phải chạy script omni-audit.sh (do tác giả cung cấp) để xuất ra file log chứng minh:

RAM có hỗ trợ ECC không.

OS đã được tắt Swap chưa.

HSM đã được kết nối và sẵn sàng chưa.


## 🚫 Quy định về Ảo hóa & Windows (Virtualization Policy)

* **Nghiêm cấm chạy Production trên Windows/WSL2:** Mọi nỗ lực vận hành nút thực tế trên môi trường Windows sẽ bị hệ thống Omni-Audit đánh dấu là "Không an toàn" và từ chối cấp quyền đồng thuận.
* **Hạn chế Ảo hóa (VMware/VirtualBox):** Chỉ chấp nhận các nền tảng ảo hóa cấp độ doanh nghiệp (như KVM/Proxmox) với điều kiện phải cấu hình **CPU Passthrough** và **Hard Disk Encryption** tuyệt đối. 
* **Khuyến nghị tối thượng:** Chạy trực tiếp trên phần cứng (Bare-metal) để đảm bảo hiệu năng 100% cho giao thức Omni-Sharding.

Tài liệu này là quy chuẩn bắt buộc. Mọi sai lệch so với cấu hình trên sẽ dẫn đến việc từ chối cấp phát chứng chỉ tham gia liên minh.
— OmniShard Architect
