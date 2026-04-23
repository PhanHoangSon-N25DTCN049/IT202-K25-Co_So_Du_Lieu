-- Thiếu NOT NULL cho Email đó là lý do khách hàng không có gmail gây lỗi hệ thống 
-- thiếu UNIQUE cho Email vì mỗi khách hàng có 1 Email tránh việc gửi chúc mừng cho 1 người 2 lần
-- thiếu CHECK cho Age cần ràng buộc tuổi phải lớn hơn 0
-- Thiếu NOT NULL cho FullName đảm bảo tính toàn vẹn cho dữ liệu tránh gửi lời chúc mừng nhưng không biết tên khách hàng

ALTER TABLE CUSTOMERS 
MODIFY COLUMN FullName VARCHAR(100) NOT NULL;

ALTER TABLE CUSTOMERS 
MODIFY COLUMN Email VARCHAR(100) NOT NULL;

ALTER TABLE CUSTOMERS 
ADD CONSTRAINT UC_Email UNIQUE (Email);

ALTER TABLE CUSTOMERS 
ADD CONSTRAINT CHK_Age CHECK (Age > 0);
