CREATE DATABASE MechKeyStore;
USE MechKeyStore;

--  DROP database MechKeyStore;

CREATE TABLE Product (
id INT PRIMARY KEY AUTO_INCREMENT,
product_name VARCHAR(255) NOT NULL,
Brand VARCHAR(255) NOT NULL,
price DECIMAL(18,2) CHECK (price >= 0),
stock INT CHECK (stock >= 0)
);

CREATE TABLE Customer (
id INT PRIMARY KEY AUTO_INCREMENT,
Customer_name VARCHAR (255) NOT NULL,
email VARCHAR(255) NOT NULL UNIQUE,
phone_number CHAR(12) NOT NULL,
Address VARCHAR(255) NOT NULL
);

CREATE TABLE Orders (
id INT PRIMARY KEY AUTO_INCREMENT,
order_date DATE default (CURRENT_DATE),
total_amount DECIMAL(18,2) NOT NULL,

customer_id INT NOT NULL,
FOREIGN KEY (customer_id) REFERENCES Customer(id)

);

CREATE TABLE Order_Detail (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,      
    product_id INT NOT NULL,
    quantity INT CHECK (quantity >= 0),
    price DECIMAL(18,2) CHECK (price >= 0),
    FOREIGN KEY (order_id) REFERENCES Orders(id),
    FOREIGN KEY (product_id) REFERENCES Product(id)
);

ALTER TABLE Product ADD category VARCHAR(255);

ALTER TABLE Product RENAME COLUMN Brand TO Company;

DROP TABLE Order_Detail;
DROP TABLE Orders;


INSERT INTO Product (id, product_name, Brand, category, price, stock) VALUES
(1, 'Aula F75', 'Aula', 'Keyboard', 1500000, 50),
(2, 'Aula F87', 'Aula', 'Keyboard', 1200000, 30),
(3, 'Akko 3068B', 'Akko', 'Keyboard', 1800000, 20),
(4, 'Gateron Yellow Switch', 'Gateron', 'Switch', 5000, 1000),
(5, 'Keycap PBT Cherry', 'OEM', 'Keycap', 500000, 15);


INSERT INTO Customer (id, Customer_name, email, phone_number, Address) VALUES
(1, 'Nguyen Van A', 'ana@gmail.com', '0901234567', 'TP.HCM'),
(2, 'Tran Thi B', 'btb@gmail.com', '0907654321', 'Ha Noi'),
(3, 'Le Van C', 'cle@gmail.com', '0912345678', ''), 
(4, 'Pham Van D', 'dpham@gmail.com', '0988888888', 'Da Nang'),
(5, 'Hoang Thi E', 'ehoang@gmail.com', '0977777777', ''); 


INSERT INTO Orders (id, order_date, total_amount, customer_id) VALUES
(1, '2026-03-01', 1500000, 1),
(2, '2026-04-05', 2400000, 2),
(3, '2026-04-10', 500000, 3),
(4, '2026-04-15', 6000000, 4),
(5, '2026-05-20', 1200000, 5);


INSERT INTO Order_Detail (id, order_id, product_id, quantity, price) VALUES
(1, 1, 1, 1, 1500000),
(2, 2, 2, 2, 1200000),
(3, 3, 5, 1, 500000),
(4, 4, 1, 4, 1500000),
(5, 5, 2, 1, 1200000);

UPDATE Product SET price = price * 1.1 WHERE Brand = 'Aula';
DELETE FROM Customer WHERE Address = '';

SELECT * FROM Product WHERE price >= 1000000 AND PRICE <= 3000000;

SELECT * FROM Orders WHERE order_date >= '2026-04-01' AND order_date <= '2026-04-30';

SELECT * FROM Product WHERE product_name LIKE "AULA%";

SELECT customer_id, total_amount FROM Orders WHERE total_amount > 5000000;

SELECT * FROM Product WHERE stock <= 10;

