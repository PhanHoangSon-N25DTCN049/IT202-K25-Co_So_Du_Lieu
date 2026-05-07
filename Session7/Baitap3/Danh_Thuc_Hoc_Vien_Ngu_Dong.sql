/*
Cơ chế của NOT EXISTS: Khi hệ thống kiểm tra một học viên, nó chỉ cần tìm thấy duy nhất một bản ghi thanh toán trong năm 2024
 là nó sẽ dừng lại ngay lập tức và trả về TRUE. Nó không quan tâm học viên đó có 2 hay 2.000 hóa đơn khác.
 ngược lại NOT IN phải quét toàn bộ danh sách nên chậm hơn
*/

-- câu lệnh hoàn chỉnh

SELECT s.email
FROM Students s
WHERE NOT EXISTS (
    SELECT 1 
    FROM Payments p 
    WHERE p.student_id = s.id 
      AND p.payment_date >= '2024-01-01' 
      AND p.payment_date <= '2024-12-31'
);