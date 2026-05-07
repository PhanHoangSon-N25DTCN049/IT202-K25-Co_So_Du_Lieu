/*
Toán tử = là toán tử so sánh đơn trị. Nó chỉ chấp nhận một giá trị duy nhất ở mỗi bên của dấu bằng.

Trước đây, ông A chỉ có 1 khóa học, Subquery trả về 1 dòng nên phép toán price = [1 giá trị] chạy đúng.
Khi ông A có thêm 2 khóa học với giá khác nhau, Subquery trả về một tập hợp (nhiều dòng).
Toán tử = không thể so sánh một giá trị đơn lẻ với một tập hợp nhiều giá trị, dẫn đến lỗi: "Subquery returns more than 1 row".
*/

-- sửa lỗi
SELECT title, price
FROM Courses
WHERE price IN (SELECT price FROM Courses WHERE instructor_id = 5);