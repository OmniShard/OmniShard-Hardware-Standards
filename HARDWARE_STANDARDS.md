# 🖥️ Tiêu Chuẩn Phần Cứng Hệ Thống OmniShard (Hardware Standards)

**Phiên bản:** 1.0.1  
**Tác giả:** Nguyễn Ngọc Hùng
**Trạng thái:** Bắt buộc đối với các nút liên minh (Consortium Nodes)  

Tài liệu này quy định các yêu cầu kỹ thuật tối thiểu và khuyến nghị để vận hành một Node trong mạng lưới OmniShardNet. Việc tuân thủ tiêu chuẩn này đảm bảo tính an toàn của mảnh khóa và hiệu năng đồng thuận toàn mạng.

---

## 1. Cấu Hình Máy Chủ (Server Specifications)

Hệ thống OmniShard chạy trên nền tảng Hyperledger Fabric, yêu cầu tài nguyên tính toán ổn định để xử lý các giao dịch mật mã ngưỡng.

| Thành phần | Mức tối thiểu (Standard) |
| :--- | :--- | :--- |
| **CPU** | 8 Cores (Hỗ trợ AES-NI)/ (Hỗ trợ Intel SGX/AMD SEV) |
| **RAM** | 16GB-32GB DDR4/DDR5 ECC |
| **Lưu trữ** | 500GB + Enterprise NVMe (RAID 10) |
| **Hệ điều hành** | Ubuntu 22.04 LTS, Hardened Linux (RHEL/CentOS 9) |

* **Lưu ý:** Ưu tiên sử dụng RAM ECC để ngăn ngừa lỗi bit trong quá trình tính toán mảnh khóa mật mã.

---

## 2. Bảo Mật Mảnh Khóa (Key Shard Security) - BẮT BUỘC

Để đảm bảo không một bên đơn lẻ nào (kể cả Quản trị viên hệ thống) có thể trích xuất mảnh khóa trái phép, các Node phải áp dụng một trong hai cơ chế sau:

### Lựa chọn A: HSM Vật lý (Physical HSM)
* Sử dụng thiết bị chuyên dụng đạt chuẩn **FIPS 140-2 Level 3**.
* Mảnh khóa được sinh ra và lưu trữ vĩnh viễn bên trong thiết bị, không bao giờ xuất hiện dưới dạng văn bản thô (Clear-text) ngoài bộ nhớ RAM.

### Lựa chọn B: Cloud HSM / TEE (Dành cho tối ưu chi phí)
* Sử dụng dịch vụ Cloud HSM từ các nhà cung cấp uy tín (Viettel IDC, FPT, AWS).
* Chi phí 1 node	Peer: 2 core/4GB RAM, Orderer: 1 core/2GB, TSS: 0.5 core/512MB
  Doanh nghiệp tham gia	1 máy chủ (4c/8GB), Docker, MSP cert, mở port 7051
* Hoặc kích hoạt **Intel SGX (Trusted Execution Environment)** để cô lập quá trình xử lý mật mã Omni-Sharding trong vùng nhớ an toàn (Enclave).

---

## 3. Tiêu Chuẩn Mạng & Kết Nối (Networking)

Đảm bảo độ trễ thấp để quy trình gom các mảnh khóa không bị gián đoạn.

* **Băng thông:** tối thiểu **30 Mbps** (Ưu tiên IP tĩnh doanh nghiệp hoặc kênh thuê riêng).
* **Độ trễ (Latency):** < **50ms** đối với các kết nối nội địa Việt Nam.
* **Tường lửa (Firewall):** * Chỉ mở các cổng gRPC cần thiết (Mặc định: 7051, 7053). 
    * Chặn toàn bộ truy cập từ IP lạ không nằm trong Whitelist của OmniShard.
* **Mã hóa đường truyền:** Bắt buộc sử dụng **mTLS (Mutual TLS)** với chứng chỉ do OmniShard Root CA cấp phát.

---

## 4. Tối Ưu Hóa Chi Phí (Cost Optimization)

Đối với các đối tác muốn tham gia thử nghiệm hoặc có ngân sách hạn chế, OmniShard hỗ trợ:
1. **Ảo hóa:** Chấp nhận chạy trên các nền tảng VPS/Cloud uy tín nếu chứng minh được cơ chế bảo mật ổ cứng (Disk Encryption).
2. **Soft-HSM:** Có thể sử dụng phần mềm giả lập HSM trong giai đoạn Development/UAT, nhưng **không được phép** dùng cho môi trường Production chứa dữ liệu thật.

---

## 5. Quy Trình Phê Duyệt Node (Node Onboarding)

Để giữ vững vai trò điều phối và bảo vệ hệ thống, mọi Node mới phải bước qua quy trình:
1. **Hardware Audit:** Gửi báo cáo thông số kỹ thuật và chứng chỉ HSM (nếu có) cho Architect.
2. **Connectivity Test:** Kiểm tra độ trễ và băng thông thực tế tới Nút Điều Phối (Orderer).
3. **Identity Issuance:** Sau khi đạt chuẩn, Architect sẽ ký số và cấp phát bộ định danh MSP (Membership Service Provider).

---
**"Tiêu chuẩn cao tạo nên niềm tin tuyệt đối."**
*— OmniShard Architect*
