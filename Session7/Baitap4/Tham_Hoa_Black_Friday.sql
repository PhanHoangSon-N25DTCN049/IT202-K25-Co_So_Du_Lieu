/*
1. Khám nghiệm tử thi (Boolean Logic)
Lỗi: NOT IN tương đương với chuỗi phép toán AND kèm so sánh <>.
Logic: id NOT IN (1, 2, NULL) trở thành (id<>1) AND (id<>2) AND (id<>NULL).
Hệ quả: Trong SQL, id <> NULL luôn là Unknown. Vì một vế Unknown nên cả biểu thức AND không bao giờ trả về TRUE. Kết quả: Truy vấn trống rỗng.

2. Giải pháp kiến trúc
Vá lỗi: Thêm điều kiện IS NOT NULL vào Subquery để loại bỏ các giá trị không xác định trước khi so sánh.
*/

-- Viết lại câu lệnh 
SELECT c.* FROM Courses c
WHERE NOT EXISTS (SELECT 1 FROM Enrollments e WHERE e.course_id = c.id);