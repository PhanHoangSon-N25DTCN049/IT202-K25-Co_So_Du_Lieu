-- cần quét bảng CUSTOMERS và trả về 2 cột FullName và Email 
-- việc sử dụng * khi select trong trường hợp này gây nghẽn cổ chai vì bảng có hàng triệu bản ghi gây quá tải hệ thống
-- cần lọc dữ liệu bằng where với các điều kiện Status khác locked, email không null, city phải là Hà nội thời gian off dài hơn 6 tháng

select fullname, email from CUSTOMERS where email is not null and status != 'locked' and city = 'Hà Nội' and  LastPurchaseDate <= '2026-4-1';