-- Giải pháp 1: Dùng OR
SELECT * FROM Orders 
WHERE reason = 'KHACH_HUY' 
   OR reason = 'QUAN_DONG_CUA' 
   OR reason = 'KHONG_CO_TAI_XE' 
   OR reason = 'BOM_HANG';
   
-- Giải pháp 2: dùng IN 
SELECT * FROM Orders 
WHERE reason IN ('KHACH_HUY', 'QUAN_DONG_CUA', 'KHONG_CO_TAI_XE', 'BOM_HANG');

/* Tiêu chí                 Giải pháp 1 (OR)                                                                  Giải pháp 2 (IN)
Mức độ code sạch           Kém. Viết lặp đi lặp lại tên cột reason, gây rối mắt khi danh sách dài             Tốt. Ngắn gọn, cấu trúc giống như một danh sách liệt kê, rất dễ đọc.
Khả năng mở rộng           Khó. Nếu có 20 nguyên nhân, câu lệnh sẽ cực kỳ dài và dễ sai sót khi copy-paste    .Dễ. Chỉ cần thêm phần tử vào trong dấu ngoặc đơn, cấu trúc không đổi.
Hiệu năng (SQL Engine)     Thấp hơn. SQL Engine phải kiểm tra từng điều kiện một theo thứ tự.                  Cao hơn. SQL Engine tối ưu hóa danh sách trong IN, thường sử dụng thuật toán tìm kiếm nhị phân hoặc băm. */ 


-- Phần backend chưa học

-- Giải pháp tối ưu nhất 
SELECT * FROM Orders
WHERE reason IN ('KHACH_HUY', 'QUAN_DONG_CUA', 'KHONG_CO_TAI_XE', 'BOM_HANG');