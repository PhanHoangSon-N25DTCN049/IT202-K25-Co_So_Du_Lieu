/* Khi dùng limit mà không có mệnh đề neo giữ thứ tự (ví dụ như order by) hệ thống sẽ lấy ra số dữ liệu đầu tiên mà nó tìm thấy gây ra việc dữ liệu đầu ra không như ý muốn*/

-- sửa lỗi đoạn code 
SELECT restaurant_name, created_at
FROM Restaurants 
ORDER BY created_at DESC
LIMIT 5;