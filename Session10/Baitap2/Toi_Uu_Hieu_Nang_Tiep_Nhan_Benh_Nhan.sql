-- Tạo bảng
CREATE TABLE Patients (
    Patient_ID INT AUTO_INCREMENT PRIMARY KEY,
    Full_Name VARCHAR(100),
    Phone VARCHAR(15),
    Age INT,
    Room_Number INT
);

-- Viết Procedure chèn 500.000 dòng
DELIMITER //
CREATE PROCEDURE InsertMockPatients()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 500000 DO
        INSERT INTO Patients (Full_Name, Phone, Age, Room_Number)
        VALUES (
            CONCAT('Patient ', i), 
            CONCAT('09', LPAD(i, 8, '0')), -- Tạo số điện thoại dạng 0900000001
            FLOOR(RAND() * 80) + 1, 
            FLOOR(RAND() * 500) + 1
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Gọi hàm để chèn dữ liệu (Chờ một lúc để DB chạy xong)
CALL InsertMockPatients();

-- Tìm kiếm một số điện thoại ngẫu nhiên (Ví dụ: 0900250000)
SELECT * FROM Patients WHERE Phone = '0900250000';

-- Dùng EXPLAIN để xem cách DB quét dữ liệu
EXPLAIN SELECT * FROM Patients WHERE Phone = '0900250000';
-- Ở kết quả EXPLAIN, cột 'type' sẽ là 'ALL' và 'rows' sẽ xấp xỉ 500.000 (Full Table Scan).


-- Viết Procedure chèn 1.000 dòng liên tục
DELIMITER //
CREATE PROCEDURE Insert1000Patients()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 1000 DO
        INSERT INTO Patients (Full_Name, Phone, Age, Room_Number)
        VALUES ('New Patient', CONCAT('08', LPAD(i, 8, '0')), 30, 101);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Chạy hàm và ghi lại thời gian thực thi
CALL Insert1000Patients();

CREATE INDEX idx_phone ON Patients(Phone);

-- Chạy lại lệnh tìm kiếm và ghi lại thời gian (chắc chắn sẽ nhanh hơn rất nhiều, gần như 0.00x giây)
SELECT * FROM Patients WHERE Phone = '0900250000';

-- Dùng EXPLAIN để kiểm tra
EXPLAIN SELECT * FROM Patients WHERE Phone = '0900250000';
-- Ở kết quả EXPLAIN, cột 'type' sẽ là 'ref', và cột 'key' sẽ là 'idx_phone'. Số 'rows' phải quét giảm xuống chỉ còn 1.

-- Chạy lại lệnh chèn 1000 dòng và ghi lại thời gian
-- Thời gian lúc này sẽ CHẬM HƠN so với Kịch bản 1 do DB phải cập nhật lại cấu trúc Index.
CALL Insert1000Patients();


/*
Tốc độ đọc (SELECT): * Trước Index: Tốn nhiều thời gian (ví dụ: > 0.5s hoặc vài giây tùy máy) vì hệ thống phải quét toàn bộ bảng (Full Table Scan) từ trên xuống dưới để tìm dòng thỏa mãn.

Sau Index: Tốc độ truy vấn tăng đột biến (ví dụ: ~0.001s). EXPLAIN cho thấy thay vì quét hàng trăm ngàn dòng, DB chỉ cần tra cứu chính xác dòng dữ liệu nhờ cấu trúc cây (B-Tree) của Index. Vấn đề "hàng dài bệnh nhân chờ đợi" đã được giải quyết.

Tốc độ ghi (INSERT/UPDATE):

Sự đánh đổi: Việc chèn 1000 dòng dữ liệu sau khi có Index tốn nhiều thời gian hơn so với lúc chưa có. Lý do là mỗi khi có một dòng mới được thêm vào, hệ thống không chỉ ghi vào ổ cứng mà còn phải cấu trúc, sắp xếp lại chỉ mục (Index) idx_phone để duy trì thứ tự tìm kiếm.

Kết luận thực tế: Trong bài toán bệnh viện, tần suất bệnh nhân cũ tra cứu thông tin tái khám (truy vấn SELECT) lớn hơn rất nhiều so với lượng bệnh nhân mới (truy vấn INSERT) trong cùng một thời điểm. Do đó, việc đánh đổi một chút tốc độ Ghi để lấy tốc độ Đọc là một phương án tối ưu và bắt buộc phải làm.
*/