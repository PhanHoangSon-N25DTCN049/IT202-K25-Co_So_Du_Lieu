/* vì khi có thêm room_name chương trình sẽ không biết hiển thị tên phòng như thế nào
ví dụ như khi có 2 phòng cùng mức giá chương trình sẽ không biết nên hiển thị phòng nào ra
khi chỉ có một dữ liệu được hiển thị*/

-- Sửa code cho đúng:
SELECT 
    hotel_id, 
    MIN(price_per_night) AS min_price
FROM Rooms
GROUP BY hotel_id;
