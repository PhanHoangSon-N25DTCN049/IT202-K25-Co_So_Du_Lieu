/*
Đề xuất Đa giải pháp (Luồng tư duy):
Hướng tiếp cận 1 (Lọc Trễ - Bad Practice): Không sử dụng mệnh đề WHERE. Gom nhóm (GROUP BY) toàn bộ dữ liệu của khách sạn (kể cả đơn Hủy, đơn Lỗi),
 sau đó dùng mệnh đề HAVING để kết hợp hàm tính toán và kiểm tra trạng thái thành công.
 
Hướng tiếp cận 2 (Lọc Sớm - Clean Code): Sử dụng mệnh đề WHERE để loại bỏ các đơn Hủy/Lỗi ngay từ đầu,
sau đó mới GROUP BY và dùng HAVING để kiểm tra điều kiện số lượng (>= 50) và doanh thu trung bình (> 3.000.000).

Nếu dùng Cách 1 (Gom nhóm rồi mới vứt đi bằng HAVING):
 Hệ thống sẽ phải đẩy toàn bộ dữ liệu (kể cả hàng triệu đơn Hủy/Lỗi) vào bộ nhớ RAM để gom nhóm và tính toán toán học (COUNT, AVG) vô ích. 
 CPU phải làm việc hết công suất để xử lý "rác", gây ra tình trạng thắt cổ chai (bottleneck) cho Database.

Nếu dùng Cách 2 (Lọc bằng WHERE ngay từ đầu): Hệ thống đã gạt bỏ ngay hàng triệu đơn Hủy/Lỗi từ lúc đọc dữ liệu thô ở ổ cứng. 
Khi dữ liệu được đưa lên RAM để GROUP BY, nó đã rất sạch và nhỏ gọn. CPU tính toán nhanh hơn gấp nhiều lần, tiết kiệm tối đa tài nguyên máy chủ.
*/

SELECT 
hotel_id,
COUNT(*) AS order_completed,
AVG(total_price) AS AVG_Price
FROM Bookings
WHERE status = 'COMPLETED'
GROUP BY hotel_id
HAVING order_completed >= 50 AND AVG_Price > 3000000;
