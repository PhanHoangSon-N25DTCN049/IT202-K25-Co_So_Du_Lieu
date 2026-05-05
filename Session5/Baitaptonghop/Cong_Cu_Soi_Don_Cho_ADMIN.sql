CREATE DATABASE IF NOT EXISTS Rikkei_Admin_Tool;
USE Rikkei_Admin_Tool;

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,         -- Đóng vai trò phân biệt đơn thường (có ID) và đơn ảo (NULL)
    total_amount INT NOT NULL,        -- Giá trị đơn hàng
    status VARCHAR(50) NOT NULL,      -- Trạng thái: PENDING, COMPLETED, CANCELLED...
    note TEXT,                        -- Ghi chú của đơn hàng
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO Orders (user_id, total_amount, status, note) VALUES
--  CÁC ĐƠN HỢP LỆ 
(1, 4500000, 'PENDING', 'Khách hối, giao gấp nhé'),   -- Có chữ "gấp", giá thỏa mãn -> Alert: Nguy hiểm
(NULL, 3000000, 'COMPLETED', 'Hệ thống tự sinh'),       -- user_id NULL, giá thỏa mãn -> Alert: Bình thường
(NULL, 5000000, 'PROCESSING', ''),                       -- user_id NULL, giá kịch trần -> Alert: Nguy hiểm
(3, 2500000, 'PENDING', 'Gửi gấp giúp mình'),            -- Có chữ "gấp", giá biên dưới -> Alert: Bình thường

--  CÁC ĐƠN DÍNH BẪY 
(2, 10000000, 'PENDING', 'Giao gấp'),                    -- BẪY 1: Có chữ "gấp" nhưng giá vượt quá 5 triệu
(4, 3500000, 'CANCELLED', 'Cần gấp trong đêm'),          -- BẪY 2: Thỏa mãn giá + chữ "gấp", nhưng status là CANCELLED
(NULL, 4000000, 'CANCELLED', 'Đơn ảo'),                  -- BẪY 3: Đơn do hệ thống sinh (NULL) nhưng đã bị CANCELLED
(6, 1500000, 'COMPLETED', 'Đơn thường, giao gấp'),       -- BẪY 4: Dưới 2 triệu

--  CÁC ĐƠN BÌNH THƯỜNG
(7, 3500000, 'PENDING', 'Giao giờ hành chính'),          -- Có user_id, không có chữ "gấp"
(8, 4200000, 'COMPLETED', 'Không có ghi chú đặc biệt');  -- Có user_id, không có chữ "gấp"

/*  Trong SQL, toán tử AND có độ ưu tiên cao hơn OR. Nếu viết các điều kiện dàn hàng ngang mà không có biện pháp "đóng gói",
 SQL sẽ thực hiện các cụm AND trước, sau đó mới đến OR
 Kỹ thuật khóa chặt bẫy: sử dụng Dấu ngoặc đơn () để nhóm các điều kiện của Bộ lọc Kép lại với nhau.
 Việc này ép SQL phải giải quyết bài toán "Hoặc" bên trong ngoặc trước, sau đó mới đem kết quả đó đi đối soát với các điều kiện bắt buộc về giá và trạng thái.*/

SELECT  *,
    -- Tùy biến hiển thị Alert_Level
    CASE 
        WHEN total_amount > 4000000 THEN 'Nguy hiểm'
        ELSE 'Bình thường'
    END AS Alert_Level
FROM Orders
WHERE 
    -- 1. Lọc khoảng giá
    total_amount BETWEEN 2000000 AND 5000000
    -- 2. Loại bỏ đơn đã hủy
    AND status != 'CANCELLED'
    -- 3. Bộ lọc kép (Dùng ngoặc đơn để phá bẫy logic)
    AND (note LIKE '%gấp%' OR user_id IS NULL)
-- 4. Sắp xếp ưu tiên đơn đắt tiền nhất
ORDER BY total_amount DESC
-- 5. Phân trang cho Trang 3
LIMIT 20 OFFSET 40;