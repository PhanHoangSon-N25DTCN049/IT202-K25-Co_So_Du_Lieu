/*dùng SUM() kết hợp CASE WHEN để kiểm tra status có phải là cancelled hay không nếu đúng thì cho bằng 1
và SUM sẽ cộng thêm 1, nếu sai thì là 0 SUM sẽ không tăng từ đó lọc ra được các đơn bị hủy*/

SELECT 
	user_id,
    COUNT(*) total_bookings,
    SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) AS total_cancelled_bookings
FROM Booking
GROUP BY user_id
HAVING 
	total_bookings >= 10 AND 
    total_cancelled_bookings > 5;
