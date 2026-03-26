# 🤝 Hướng dẫn Đóng góp & Tích hợp OmniShard (CONTRIBUTING)

Chào mừng các đối tác và nhà phát triển quan tâm đến hệ sinh thái **OmniShard**. Để đảm bảo tính toàn vẹn của giao thức **Mật mã phân mảnh Omni (Omni-Sharding)** và an toàn cho liên minh,
mọi đóng góp phải tuân thủ quy trình nghiêm ngặt dưới đây.

## ⚖️ Nguyên tắc "Kiến trúc sư trưởng" (Architect-First)
OmniShard không phải là một dự án mã nguồn mở tự do hoàn toàn. Đây là một hệ thống **Điều phối Mật mã có kiểm soát**.
* **Quyền quyết định:** Mọi thay đổi liên quan đến logic chia mảnh khóa, thuật toán đồng thuận ngưỡng và giao thức kết nối Peer-to-Peer phải được phê duyệt trực tiếp bởi **OmniShard**.
* **Tính bảo mật:** Không chấp nhận bất kỳ mã nguồn nào có dấu hiệu tạo ra "Backdoor" hoặc làm suy yếu ngưỡng bảo mật đã thiết lập.

---

## 🛠️ Quy trình Đóng góp (Contribution Workflow)

### 1. Đề xuất Thay đổi (Open an Issue)
Trước khi viết code, bạn phải mở một **Issue** để mô tả mục đích:
* Tại sao cần thay đổi này?
* Nó có ảnh hưởng đến hiệu năng của Hyperledger Fabric không?
* Nó có làm thay đổi cơ chế nắm giữ mảnh khóa của các bên liên minh không?

### 2. Tiêu chuẩn Mã nguồn (Coding Standards)
* Mã nguồn phải tuân thủ định dạng của dự án.
* Mọi tính năng mới phải đi kèm với **Unit Test** và **Integration Test** chứng minh tính đúng đắn của thuật toán phân mảnh.
* Tài liệu hướng dẫn (Documentation) phải được cập nhật tương ứng.

### 3. Quy trình Pull Request (PR)
* Chỉ gửi PR sau khi Issue đã được Architect chấp thuận.
* PR phải được ký bằng **GPG Signature** để xác minh danh tính người đóng góp.
* **Kiểm toán (Auditing):** Architect sẽ tiến hành kiểm tra mã nguồn (Code Review) THỦ CÔNG từng dòng để đảm bảo không có mã độc hay cài cắm gian lận.

---

## 🏗️ Quy định dành cho Đối tác Liên minh (Consortium Partners)
Nếu bạn là một tổ chức muốn tham gia vận hành một Node trong mạng lưới:
1. **Xác minh Phần cứng:** Phải gửi bản mô tả chi tiết phần cứng đạt chuẩn theo `HARDWARE_STANDARDS.md`.
2. **Yêu cầu Định danh:** Gửi yêu cầu cấp phát chứng chỉ số tới **Root CA** của OmniShard.
3. **Thỏa thuận Vận hành:** Ký cam kết không tự ý Fork mã nguồn để tạo ra các biến thể làm
