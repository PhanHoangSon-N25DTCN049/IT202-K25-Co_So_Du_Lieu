-- Giải pháp 1: Dùng lệnh DELETE FROM có chọn lọc
-- giải pháp 2: Không xóa thật, mà dùng lệnh UPDATE để chuyển một cờ (flag) ví dụ: is_deleted = 1
-- so sánh 2 giải pháp: ở giải pháp 1: dữ liệu bị mất đi làm giảm dung lượng bộ nhớ còn 2 thì không dữ liệu vẫn còn đó,
-- cách 1 làm bảng mất dữ liệu hoàn toàn không thể tra cứu lại khi kiểm toán cách 2 thì vẫn có thể tra cứu lại khi cần
-- cách 1 giúp tăng tốc độ truy vấn cách 2 làm chậm hơn vì phải quét thêm điều kiện is_deleted = 1

ALTER TABLE ORDERS ADD COLUMN is_deleted TINYINT(1) DEFAULT 0;
UPDATE ORDERS 
SET is_deleted = 1 
WHERE Status = 'Canceled';

-- Vấn cho nền tảng
SELECT * FROM ORDERS WHERE is_deleted=0;

-- Truy vấn cho kế toán
SELECT * FROM ORDERS 