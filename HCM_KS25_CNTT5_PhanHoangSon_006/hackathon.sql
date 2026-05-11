-- tạo database
CREATE DATABASE library_db;
USE library_db;

-- Tạo bảng
CREATE TABLE Users (
user_id VARCHAR(5) PRIMARY KEY NOT NULL,
full_name VARCHAR(100) NOT NULL,
email VARCHAR(100) NOT NULL UNIQUE,
phone VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE Categories (
category_id VARCHAR(5) PRIMARY KEY NOT NULL,
category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Books (
book_id VARCHAR(5) PRIMARY KEY NOT NULL,
title VARCHAR(100) NOT NULL UNIQUE,

category_id VARCHAR(5) NOT NULL,
FOREIGN KEY (category_id) REFERENCES Categories(category_id),

price DECIMAL(10,2) NOT NULL,
stock INT CHECK (stock >= 0)
);

CREATE TABLE Borrows (
borrow_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
status VARCHAR(20) CHECK (status IN ('Borrowing', 'Returned', 'Lost')), 
borrow_date DATE DEFAULT (CURRENT_DATE),

user_id VARCHAR(5) NOT NULL,
FOREIGN KEY (user_id) REFERENCES Users(user_id),

book_id VARCHAR(5) NOT NULL,
FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- Chèn dữ liệu
INSERT INTO Users
(user_id, full_name, email, phone) 
VALUES 
('U01', 'Nguyễn Văn AN', 'a@m.com', '0912345678'),
('U02', 'Trần Thị Bích', 'b@m.com', '0923456789'),
('U03', 'Lê Hoàng Minh', 'mi@m.com', '0934567890'),
('U04', 'Phạm Thu Hà', 'h@m.com', '0945678901'),
('U05', 'Võ Quốc Huy', 'hu@m.com', '0956789012');

INSERT INTO Categories
(category_id, category_name) 
VALUES
('C01', 'IT'),
('C02', 'Literature'),
('C03', 'Science'),
('C04', 'History');

INSERT INTO Books
(book_id, title, category_id, price, stock) 
VALUES 
('B01', 'Clean Code', 'C01', '250000.00', 10),
('B02', 'Design Pattern', 'C01', '300000.00', 5),
('B03', 'Tat Den', 'C02', '50000.00', 20),
('B04', 'Universe', 'C03', '150000.00', 8),
('B05', 'Sapiens', 'C04', '200000.00', 15);

INSERT INTO Borrows
(borrow_id,user_id, book_id, borrow_date, status) 
VALUES 
('1', 'U01', 'B01', '2025-10-01', 'Borrowing'),
('2', 'U02', 'B03', '2025-10-02', 'Returned'),
('3', 'U01', 'B02', '2025-10-03', 'Returned'),
('4', 'U04', 'B05', '2025-10-04', 'Lost'),
('5', 'U05', 'B01', '2025-10-05', 'Borrowing');

-- cập nhật sách Sapiens
UPDATE Books
SET stock = stock + 10, price = price * 1.05 
WHERE title = 'Sapiens';

-- Cập Nhật Số Điện thoại User U03
UPDATE Users 
SET phone = '0999999999'
WHERE user_id = 'U03';


-- Xóa bản ghi sách trong bảng Borrow
-- Phải tắt chế độ safe update mới chạy được 
DELETE FROM Borrows 
WHERE status = 'Returned' AND borrow_date < '2025-10-03';


-- Phần 2: Truy vấn dữ liệu cơ bản
-- liệt kê danh sách có giá đền bù > 100000 AND <250000 và stock > 0
SELECT book_id, title, price
FROM Books
WHERE (price > 100000.00 AND price < 250000.00) AND stock > 0;

-- lấy thông tin full_name, email của những người có tên họ Nguyen
SELECT full_name, email
FROM users
WHERE full_name LIKE 'Nguyễn%';

-- Lấy ra 3 sách có đền bù cao nhất
SELECT *
FROM Books
ORDER BY price DESC
LIMIT 3;

-- Lấy hiển thị danh sách bỏ qua 2 sách đầu tiên và lấy 2 sách tiếp theo
SELECT title, stock
FROM Books
ORDER BY stock
LIMIT 2 OFFSET 2;

-- Phần 3: Truy vấn dữ liệu nâng cao
-- Hiển thị danh sách của 3 bảng có trạng thái là 'Borrowing'
SELECT bo.borrow_id, u.full_name, b.title, bo.borrow_date
FROM Borrows bo 
JOIN Users u ON (u.user_id = bo.user_id) 
JOIN Books b ON (b.book_id = bo.book_id)
WHERE bo.status = 'Borrowing';

-- Liệt kê danh mục và tựa sách thuộc danh mục đó (hiển thị cả danh mục chưa có cuốn sách nào)
SELECT c.category_name, b.title
FROM Categories c 
LEFT JOIN Books b ON (b.category_id = c.category_id);

-- tính tổng số lượt mượn sách theo từng trạng thái
SELECT status, COUNT(status)
FROM Borrows
GROUP BY status;

-- Thống kê sách mà mỗi người dùng đã mượn (chỉ hiện thị tên người có 2 lượt mượn trở lên)
SELECT u.full_name, COUNT(bo.user_id) AS Count_muon
FROM Users u JOIN Borrows bo ON (bo.user_id = u.user_id)
GROUP BY u.full_name
HAVING COUNT(bo.user_id) >= 2;

-- Lấy thông tin sách có giá đền bù nhỏ hơn giá trung bình tất cả sách
SELECT book_id, title, price
FROM Books
WHERE price < (SELECT AVG(price) FROM Books);

-- Hiển thị thông tin name và phone của người mượn cuốn sách Clean Code 
SELECT u.full_name, u.phone 
FROM Users u 
JOIN Borrows bo ON (bo.user_id = u.user_id)
JOIN Books b ON (b.book_id = bo.book_id) 
WHERE b.title = 'Clean Code';
