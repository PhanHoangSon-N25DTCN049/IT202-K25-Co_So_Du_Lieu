-- Nhân viên IT đã quên where khi dùng lệnh update để chỉ định cập nhật cho sản phẩm điện tử gây hỏng toàn bộ dữ liệu

-- Tạo bảng mẫu
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(15, 2),
    stock_quantity INT,
    category VARCHAR(100),
    created_at DATE
);

-- Chèn dữ liệu mẫu
INSERT INTO products (product_name, price, stock_quantity, category, created_at) VALUES
('iPhone 15 Pro', 25000000, 50, 'Electronics', '2024-01-10'),
('MacBook Air M2', 28000000, 30, 'Electronics', '2024-01-12'),
('Samsung S23', 19000000, 45, 'Electronics', '2024-01-15'),
('Mechanical Keyboard', 1500000, 100, 'Accessories', '2024-01-20'),
('Logitech Mouse', 800000, 120, 'Accessories', '2024-01-22');

-- sửa mã lệnh cho đúng
update products set price = price * 0.9 where category = 'Electronics';