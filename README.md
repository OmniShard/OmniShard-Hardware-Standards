#Dự án: OmniShard (Giao thức Mật mã Phân mảnh Ngành dọc)
Tác giả & Kiến trúc sư: Nguyễn Ngọc Hùng (OmniShard Architect)
Công nghệ lõi: Omni-Sharding Threshold Protocol v1.0

THÔNG BÁO BẢN QUYỀN & GIẤY PHÉP (IMPORTANT)
Dự án OmniShard và bộ Tiêu chuẩn phần cứng đi kèm được bảo hộ bởi giấy phép GNU AGPLv3.

Điều này có nghĩa là:

Bắt buộc công khai: Nếu bất kỳ tổ chức nào sử dụng mã nguồn này để cung cấp dịch vụ qua mạng (Cloud/SaaS),
các bạn PHẢI công khai toàn bộ mã nguồn chỉnh sửa cho cộng đồng. Không có ngoại lệ cho các hệ thống "nội bộ" nếu có kết nối mạng.
Quyền sở hữu trí tuệ: Mọi tài liệu về tiêu chuẩn phần cứng và giao thức chia mảnh khóa (ví dụ như 7/10 ) là tài sản trí tuệ của tác giả.
Việc sử dụng cho mục đích thương mại hoặc hình thành liên minh (Consortium) mà không có sự xác nhận của tác giả là vi phạm điều khoản sử dụng.
Mọi nỗ lực thay đổi logic hệ thống nhằm gạt bỏ vai trò điều phối của tác giả sẽ dẫn đến việc chấm dứt quyền sử dụng giấy phép ngay lập tức.


# 🛡️ OmniShard: Giao Thức Mật Mã Phân Mảnh Ngành Dọc (Omni-Sharding)

![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)
![Architecture: Hyperledger Fabric](https://img.shields.io/badge/Architecture-Hyperledger%20Fabric-orange.svg)
![Security: 7/10 Threshold](https://img.shields.io/badge/Security-7%2F10%20Threshold-red.svg)

**OmniShard** là giải pháp hạ tầng bảo mật dựa trên nền tảng Blockchain doanh nghiệp (Hyperledger Fabric), tiên phong trong việc ứng dụng cơ chế **Mật mã phân mảnh Omni (Omni-Sharding)** để giải quyết bài toán niềm tin và bảo mật dữ liệu tại thị trường Việt Nam.

## 💡 Tầm nhìn & Triết lý
Trong một hệ sinh thái đa bên, niềm tin không nên đặt vào một cá nhân hay tổ chức đơn lẻ. OmniShard được xây dựng để trở thành **Lá chắn số**, nơi dữ liệu không được lưu trữ tập trung mà được phân rã thành các mảnh khóa mật mã, phân tán cho các bên liên minh nắm giữ.

> "Chúng tôi không giữ bí mật của bạn. Chúng tôi cung cấp giao thức để tập thể cùng bảo vệ bí mật đó."

---

## 🏗️ Kiến trúc lõi: Omni-Sharding 7/10
Hệ thống vận hành dựa trên thuật toán mật mã ngưỡng tùy chỉnh, tối ưu hóa cho hạ tầng mạng nội địa:

* **Phân mảnh (Sharding):** Khóa giải mã được chia thành **10 mảnh độc lập**.
* **Ngưỡng thực thi (Threshold):** Cần ít nhất **7/10 nút (Nodes)** đồng thuận để tái thiết lập khóa và giải mã dữ liệu.
* **Tính phi tập trung:** Không một bên đơn lẻ nào (kể cả quản trị viên hệ thống) có đủ quyền năng tự ý truy cập dữ liệu trái phép.

---

## 📋 Tiêu chuẩn phần cứng (Hardware Standards)
Để đảm bảo tính toàn vẹn của liên minh, các Node tham gia bắt buộc phải tuân thủ bộ tiêu chuẩn phần cứng được niêm yết tại Repo này:
* Hỗ trợ mã hóa phần cứng (HSM/TPM tích hợp).
* Khả năng chịu lỗi (Fault Tolerance) đạt mức doanh nghiệp.
* Tuân thủ các quy định về An toàn thông tin của Việt Nam.

---

⚖️ Giấy phép & Bản quyền (License)
Tài liệu tại Repo được phát hành dưới giấy phép **GNU Affero General Public License v3.0 (AGPL-3.0)**.

Điều khoản bắt buộc:
1.  **Tính minh bạch:** Mọi chỉnh sửa, phái sinh từ mã nguồn OmniShard khi triển khai trên môi trường mạng **PHẢI** được công khai mã nguồn tương ứng.
2.  **Ghi công:** Mọi hình thức sử dụng giao thức Omni-Sharding phải ghi rõ tác giả gốc và dự án OmniShard.
3.  **Bảo hộ thương hiệu:** Tên gọi "OmniShard" và kiến trúc "Omni-Sharding" là tài sản trí tuệ của tác giả. Nghiêm cấm mọi hành vi trục lợi hoặc bất hợp pháp nhằm tước đoạt quyền điều phối của tác giả trong mạng lưới liên minh.

---

🤝 Tham gia Liên minh
Nếu bạn là doanh nghiệp hoặc cơ quan muốn tích hợp giải pháp OmniShard làm lớp bảo mật trung gian:
1.  Đọc kỹ file `CONTRIBUTING.md`.
2.  Đảm bảo phần cứng đạt chuẩn trong thư mục `/Hardware-Specs`.
3.  Liên hệ với **OmniShard Architect (Nguyễn Ngọc Hùng)** (thay mặt hội đồng OmniShard) và đại diện các cơ quan để cấp phát định danh Root CA.

---
**Designed by Nguyễn Ngọc Hùng - Architect of Trust**
