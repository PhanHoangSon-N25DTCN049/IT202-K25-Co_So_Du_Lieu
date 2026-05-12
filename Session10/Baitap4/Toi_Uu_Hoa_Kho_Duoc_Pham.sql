-- 1. Tạo bảng Kho Dược Phẩm
CREATE TABLE Pharmacy_Inventory (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Drug_Name VARCHAR(255),
    Batch_Number VARCHAR(50),
    Expiry_Date DATE,
    Quantity INT
);

-- 2. Tạo Procedure để chèn dữ liệu mẫu (Giả lập khoảng 100.000 dòng để test nhanh)
DELIMITER //
CREATE PROCEDURE InsertMockPharmacy()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 100000 DO
        INSERT INTO Pharmacy_Inventory (Drug_Name, Batch_Number, Expiry_Date, Quantity)
        VALUES (
            CONCAT('Drug_', FLOOR(RAND() * 1000)), -- Tạo ngẫu nhiên 1000 tên thuốc
            CONCAT('BATCH_', LPAD(FLOOR(RAND() * 5000), 4, '0')),
            DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 1000) DAY), -- Hạn sử dụng ngẫu nhiên
            FLOOR(RAND() * 500) + 1
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Gọi hàm chèn dữ liệu
CALL InsertMockPharmacy();

CREATE INDEX idx_drug_name ON Pharmacy_Inventory(Drug_Name);
CREATE INDEX idx_expiry_date ON Pharmacy_Inventory(Expiry_Date);

-- Kiểm tra hiệu năng bằng EXPLAIN
EXPLAIN SELECT * FROM Pharmacy_Inventory 
WHERE Drug_Name = 'Drug_500' AND Expiry_Date = '2025-12-31';

-- Xóa 2 index cũ
DROP INDEX idx_drug_name ON Pharmacy_Inventory;
DROP INDEX idx_expiry_date ON Pharmacy_Inventory;

-- Tạo 1 Composite Index trên cả 2 cột
CREATE INDEX idx_name_expiry ON Pharmacy_Inventory(Drug_Name, Expiry_Date);

-- Kiểm tra lại bằng EXPLAIN
EXPLAIN SELECT * FROM Pharmacy_Inventory 
WHERE Drug_Name = 'Drug_500' AND Expiry_Date = '2025-12-31';

/*
Composite Index cấu trúc dữ liệu theo dạng phân cấp từ trái sang phải. Nó sẽ sắp xếp theo Drug_Name trước, sau đó đối với các thuốc trùng tên, nó lại sắp xếp tiếp theo Expiry_Date. Do đó, khi truy vấn cả 2 điều kiện cùng lúc, Database đi thẳng được tới Node chứa dữ liệu mà không cần lọc 2 lần như khi dùng 2 Index rời rạc.
Khi nhân viên kho tìm kiếm bằng câu lệnh WHERE Drug_Name LIKE '%Paracetamol%'
Index tiêu chuẩn sử dụng cấu trúc cây B-Tree (Binary Tree) dựa trên việc so sánh ký tự từ trái sang phải. Khi bạn đặt dấu % ở đầu từ khóa (Leading wildcard), hệ thống không biết chữ cái đầu tiên là gì để duyệt cây. Hậu quả là B-Tree bị vô hiệu hóa, Database buộc phải quay lại quét toàn bộ bảng (Full Table Scan).

Thay vì tìm %keyword%, hãy hướng dẫn hoặc code giao diện để tìm kiếm dạng keyword% (chỉ có wildcard ở cuối).
Ví dụ: WHERE Drug_Name LIKE 'Paracetamol%'. Lúc này chữ 'P' đã xác định, B-Tree sẽ hoạt động trở lại.
*/