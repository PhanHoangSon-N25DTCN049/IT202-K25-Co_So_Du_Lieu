CREATE TABLE authors (
    id INT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    birth_year INT,
    nationality VARCHAR(100)
);

CREATE TABLE books (
    id INT PRIMARY KEY,
    book_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    author_id INT,
    price DECIMAL(10, 2) DEFAULT 0 CHECK (price >= 0),
    publish_year INT,
    FOREIGN KEY (author_id) REFERENCES authors(id)
);

CREATE TABLE customers (
    id INT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    registration_date DATE DEFAULT (CURRENT_DATE)
);

-- 1. Thêm 3 tác giả
INSERT INTO authors (id, full_name, birth_year, nationality) VALUES
(1, 'Nguyễn Nhật Ánh', 1955, 'Việt Nam'),
(2, 'Conan Doyle', 1859, 'Anh'),
(3, 'Dale Carnegie', 1888, 'Mỹ');

-- 2. Thêm 8 cuốn sách (Văn học, Trinh thám, Kỹ năng...)
INSERT INTO books (id, book_name, category, author_id, price, publish_year) VALUES
(1, 'Mắt biếc', 'Văn học', 1, 110000, 1990),
(2, 'Cho tôi xin một vé đi tuổi thơ', 'Văn học', 1, 85000, 2008),
(3, 'Sherlock Holmes: Chiếc nhẫn tình cờ', 'Trinh thám', 2, 120000, 1887),
(4, 'Sherlock Holmes: Con chó của dòng họ Baskerville', 'Trinh thám', 2, 150000, 1902),
(5, 'Đắc Nhân Tâm', 'Kỹ năng', 3, 95000, 1936),
(6, 'Quẳng gánh lo đi và vui sống', 'Kỹ năng', 3, 80000, 1948),
(7, 'Tôi thấy hoa vàng trên cỏ xanh', 'Văn học', 1, 125000, 2010),
(8, 'Thung lũng sợ hãi', 'Trinh thám', 2, 115000, 1915);

-- 3. Thêm 5 khách hàng
INSERT INTO customers (id, full_name, email, phone) VALUES
(1, 'Trần Văn A', 'vana@gmail.com', '0901234567'),
(2, 'Lê Thị B', 'thib@gmail.com', '0912345678'),
(3, 'Nguyễn Văn C', 'vanc@gmail.com', '0923456789'),
(4, 'Phạm Thị D', 'thid@gmail.com', '0934567890'),
(5, 'Hoàng Văn E', 'vane@gmail.com', '0945678901');


INSERT INTO customers (id, full_name, email, phone) 
VALUES (6, 'Người Dùng Mới', 'vana@gmail.com', '0999999999');
-- Câu lệnh này sẽ bị lỗi do email 'vana@gmail.com' đã tồn tại ở khách hàng ID 1
-- Hệ thống sẽ báo lỗi: "Duplicate entry 'vana@gmail.com' for key 'email'"

/* Giải thích: 
Trong cấu trúc bảng 'customers' đã tạo, cột 'email' có ràng buộc UNIQUE. 
Ràng buộc này đảm bảo không có hai khách hàng nào có cùng địa chỉ email.
Khi chạy lệnh trên, CSDL sẽ từ chối hành động INSERT để bảo vệ tính toàn vẹn dữ liệu.
*/