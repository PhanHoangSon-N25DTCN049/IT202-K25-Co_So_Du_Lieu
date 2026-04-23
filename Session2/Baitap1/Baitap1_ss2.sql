-- Lỗi: Sử dụng DECIMAL(18, 2).
-- Lý do: Trong các hệ thống thương mại điện tử, các phép tính như tính thuế (VAT), phần trăm giảm giá (Discount), hoặc chia đơn hàng thường tạo ra nhiều hơn 2 chữ số thập phân. Việc chỉ để scale (phần thập phân) là 2 sẽ khiến hệ thống tự động làm tròn quá sớm trong các phép tính trung gian
-- Lỗi: Sử dụng ProductName VARCHAR(255) và đặc biệt là Description TEXT.
-- Lý do: ProductName VARCHAR(255): Mặc dù VARCHAR là kiểu dữ liệu độ dài biến đổi, nhưng việc khai báo quá lớn so với thực tế (tên sản phẩm ngắn) có thể gây lãng phí bộ nhớ đệm.
-- Description TEXT: Đây là lỗi chính. Kiểu TEXT được lưu trữ ở một vùng nhớ riêng ngoài bảng chính (off-page storage). Việc truy xuất dữ liệu từ kiểu TEXT đòi hỏi thêm các thao tác I/O để đọc con trỏ, gây chậm hệ thống và tốn tài nguyên quản lý trang bộ nhớ hơn so với VARCHAR

CREATE TABLE PRODUCTS (
    ID INT PRIMARY KEY AUTO_INCREMENT, 
    ProductName VARCHAR(100) NOT NULL,
   Price DECIMAL(19, 4) NOT NULL DEFAULT 0, 
   Description VARCHAR(1000)
);
