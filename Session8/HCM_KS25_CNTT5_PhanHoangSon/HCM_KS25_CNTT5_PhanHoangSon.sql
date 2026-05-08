CREATE DATABASE BookStoreDB;
USE BookStoreDB;

CREATE TABLE Category (
category_id INT PRIMARY KEY AUTO_INCREMENT,
category_name VARCHAR(100) NOT NULL,
description VARCHAR(255) NOT NULL
);


CREATE TABLE Book (
book_id INT PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(150) NOT NULL,
status INT DEFAULT 1,
publish_date DATE,
price DECIMAL(18,2) CHECK (price >= 0),
category_id INT,
FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE BookOrder (
order_id INT PRIMARY KEY AUTO_INCREMENT,
customer_name VARCHAR(100) NOT NULL,
order_date DATE DEFAULT (CURRENT_DATE),
delivery_date DATE,

book_id INT,
FOREIGN KEY (book_id) REFERENCES Book(book_id) ON DELETE CASCADE
);

-- thêm cột 
ALTER TABLE Book ADD author_name VARCHAR(100) NOT NULL;

-- Sửa dữ liệu
ALTER TABLE BookOrder MODIFY COLUMN customer_name VARCHAR(200);

-- thêm ràng buộc
ALTER TABLE BookOrder ADD CONSTRAINT delivery_date CHECK(delivery_date >= order_date);


-- Thêm dữ liệu
INSERT INTO Category (category_id, category_name, description) VALUES
(1,'IT & Tech','Sách lập trình'),
(2,'Business','Sách kinh doanh'),
(3,'Novel','Tiểu thuyết');

INSERT INTO Book(book_id, title, status, publish_date, price, category_id, author_name) VALUES
(1,'Clean Code',1, '2020-05-10', 500000, 1,'Robert C. Martin'),
(2,'Đắc Nhân Tâm', 0 , '2020-05-10', 150000, 2,'Dale Carnegie'),
(3,'JavaScript Nâng cao', 1, '2020-05-10', 350000, 1,'Kyle Simpson'),
(4,'Nhà Giả Kim', 0 , '2020-05-10', 120000, 3,'Paulo Coelho');

INSERT INTO BookOrder(order_id, customer_name, book_id, order_date, delivery_date) VALUES
(101, 'Nguyen Hai Nam', 1, '2025-01-10', '2025-01-15'),
(102, 'Tran Bao Ngoc', 3, '2025-02-05', '2025-02-10'),
(103, 'Le Hoang Yen', 4, '2025-03-12', NULL);


-- cập nhật dữu liệu
UPDATE Book SET price = price + 50000 WHERE category_id = 1;

UPDATE BookOrder SET delivery_date = '2025-12-31' WHERE delivery_date = NULL;

-- Xóa dữ liệu
DELETE FROM BookOrder WHERE order_date < '2025-02-01';

-- truy vấn dữ liệu
SELECT title, author_name, 
	CASE 
        WHEN status = 1 THEN 'Còn hàng' 
        WHEN status = 0 THEN 'Hết hàng' 
    END AS status_name
FROM books;

SELECT 
    UPPER(title) AS title_uppercase, 
    YEAR(CURDATE()) - YEAR(publish_date) AS years_since_published
FROM books;

SELECT b.title, b.price, c.category_name
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id;

SELECT * FROM books 
ORDER BY price DESC LIMIT 2;

SELECT category_id, COUNT(*) AS total_books
FROM books
GROUP BY category_id HAVING COUNT(*) >= 2;

SELECT * FROM books 
WHERE price > (SELECT AVG(price) FROM books);

SELECT * FROM books 
WHERE book_id IN (SELECT DISTINCT book_id FROM order_details);

SELECT * FROM books b1
WHERE price = (SELECT MAX(price) FROM books b2 WHERE b2.category_id = b1.category_id);