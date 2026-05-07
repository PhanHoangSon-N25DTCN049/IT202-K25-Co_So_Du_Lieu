/*
Vấn đề: Khi dùng AVG() thông thường, SQL sẽ gộp (aggregate) tất cả các dòng lại thành một dòng duy nhất, khiến bạn mất đi chi tiết từng khóa học.
Tác dụng: Việc đặt một Scalar Subquery (Truy vấn lồng đơn trị) vào mệnh đề SELECT cho phép tính toán một giá trị tổng quát (như giá trung bình sàn) và "gắn" giá trị đó vào từng dòng của bảng chính.
Tại sao giải quyết được bài toán: Nó tạo ra một "cột ảo" chứa giá trị hằng số (giá TB) song song với các cột chi tiết (title, price). Nhờ đó, bạn có thể thực hiện phép trừ trực tiếp trên từng dòng mà không cần dùng đến GROUP BY.
*/

-- viết câu lệnh
SELECT 
    title, 
    price, 
    (price - (SELECT AVG(price) FROM Courses)) AS Price_Difference
FROM Courses;