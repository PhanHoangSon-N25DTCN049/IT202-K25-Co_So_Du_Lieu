/*
Khi dùng NOT IN, máy tính đi kiểm tra xem phòng của bạn có nằm ngoài danh sách đã đặt hay không.

Nhưng nếu trong danh sách có một phòng bị NULL (ẩn danh/không xác định), máy tính sẽ e ngại:
 "Nhỡ đâu cái phòng ẩn danh kia chính là phòng mình đang tìm thì sao?". Do đó, nó trả lời là: "Không chắc chắn".

Mệnh đề WHERE có nguyên tắc là chỉ lấy những dữ liệu chắc chắn ĐÚNG 100%. 
Vì bị dính chữ "Không chắc chắn", nó gạch bỏ toàn bộ danh sách phòng. Hậu quả là bảng kết quả trống trơn!


dùng LEFT JOIN gom hết các phòng lại sau đó dùng IS NULL để lọc ra các phòng chết 
*/

-- hoàn thiện code
SELECT 
    r.room_id, 
    r.room_name 
FROM 
    Rooms r
LEFT JOIN 
    Bookings b ON r.room_id = b.room_id
WHERE 
    b.room_id IS NULL;
    
    