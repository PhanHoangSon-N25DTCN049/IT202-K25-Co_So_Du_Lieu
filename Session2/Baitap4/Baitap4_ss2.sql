-- Giải pháp 1: Thay đổi trực tiếp (Direct Alter)
-- Sử dụng lệnh ALTER TABLE USERS MODIFY Phone VARCHAR(15);. sau đó dùng UPDATE để bù số 0.
-- Giải pháp 2: Chiến lược "Xây mới - Chuyển nhà" (Shadow Table / Online Migration)
-- Tạo một cột tạm thời mới với kiểu VARCHAR(15), copy dữ liệu từ cột cũ sang cột mới (có xử lý thêm số 0), sau đó xóa cột cũ và đổi tên cột mới.
-- Tiêu chí				Giải pháp 1: Direct Alter												Giải pháp 2: Shadow Column (Khuyên dùng)
-- Độ an toàn			Thấp. Dễ gây lock bảng lâu (2 triệu dòng), làm sập ứng dụng.			Cao. Cột mới không ảnh hưởng đến luồng dữ liệu hiện tại của cột cũ.
-- Tính toàn vẹn		Khó kiểm soát việc mất số 0 trong quá trình convert.					Dễ dàng format lại số điện thoại (thêm số 0) khi copy.
-- Thời gian downtime	Có thể gây treo hệ thống trong lúc chờ DB cập nhật toàn bộ hàng.		Gần như không có downtime (Zero Downtime).
-- Độ phức tạp			Đơn giản về câu lệnh.													Phức tạp hơn, cần nhiều bước thực thi.


ALTER TABLE USERS ADD COLUMN Phone_new VARCHAR(15);
UPDATE USERS SET Phone_new = LPAD(CAST(Phone AS CHAR), 10, '0');
ALTER TABLE USERS DROP COLUMN Phone,
RENAME COLUMN Phone_new TO Phone;
