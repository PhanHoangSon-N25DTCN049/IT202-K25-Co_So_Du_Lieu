/*  trong hầu hết các ngôn ngữ lập trình toán tử AND có độ ưu tiên cao hơn OR nên khi viết:
 WHERE district = 'Quận 1' OR district = 'Quận 3' AND rating > 4.0  
 chương trình sẽ chạy district = 'Quận 3' AND rating > 4.0 trước rồi mới chạy OR
 khi viết như vậy danh sách sẽ bao gồm cả các quán bị đánh giá xấu ở quận 1 và gây phẫn nộ cho khách hàng vip*/


-- Viết lại câu lệnh cho đúng
SELECT restaurant_name, address, rating
FROM Restaurants
WHERE (district = 'Quận 1' OR district = 'Quận 3') AND rating > 4.0;