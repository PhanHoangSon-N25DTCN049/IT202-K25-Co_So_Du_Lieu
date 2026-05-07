/*
Derived Table là một bảng ảo được tạo ra từ kết quả của một câu lệnh SELECT nằm trong mệnh đề FROM.
 Nó không tồn tại vật lý trong cơ sở dữ liệu mà chỉ tồn tại tạm thời trong lúc câu lệnh thực thi.
 
 Theo chuẩn SQL, mọi bảng xuất hiện ở mệnh đề FROM đều phải có một cái tên để hệ thống có thể tham chiếu đến các cột của nó.
 Nếu không có Alias, MySQL sẽ không biết gọi bảng tạm này là gì khi bạn thực hiện các phép tính bên ngoài, dẫn đến lỗi: "Every derived table must have its own alias".
*/

-- sửa câu lệnh cho đúng
SELECT SUM(total_spent) 
FROM (
    SELECT student_id, SUM(amount) AS total_spent
    FROM Payments
    GROUP BY student_id
    HAVING SUM(amount) > 10000000
) AS VipStudents; -- Thêm Alias ở đây để hết lỗi