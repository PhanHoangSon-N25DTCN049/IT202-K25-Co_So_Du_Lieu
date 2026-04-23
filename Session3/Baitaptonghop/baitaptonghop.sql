-- xóa hết dữ liệu có size null và price âm

CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    size VARCHAR(5),
    price DECIMAL(10, 2)
);


INSERT INTO products (product_id, product_name, size, price) VALUES
('P01', 'Áo sơ mi trắng', 'L', 250000),
('P02', 'Quần Jean xanh', 'M', 450000),
('P03', 'Áo thun Basic', 'XL', 150000),
('P04', 'Áo hoodie', NULL, -200000);

-- 1. Cập nhật giá P02 thành 400,000
UPDATE products 
SET price = 400000 
WHERE product_id = 'P02';

-- 2. Tăng giá tất cả sản phẩm lên 10%
UPDATE products 
SET price = price * 1.1;

DELETE FROM products 
WHERE product_id = 'P03';


-- 1. Xem toàn bộ sản phẩm
SELECT * FROM products;

-- 2. In nhãn sản phẩm (Chỉ tên và Size)
SELECT product_name, size FROM products;

-- 3. Tìm sản phẩm có giá > 300,000
SELECT * FROM products 
WHERE price > 300000;