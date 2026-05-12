-- 1. Khởi tạo bảng chi nhánh miền Bắc
CREATE TABLE Records_North (
    Record_ID INT PRIMARY KEY,
    Patient_Name VARCHAR(100),
    Diagnosis TEXT,
    Record_Date DATE
);

-- 2. Khởi tạo bảng chi nhánh miền Nam
CREATE TABLE Records_South (
    Record_ID INT PRIMARY KEY,
    Patient_Name VARCHAR(100),
    Diagnosis TEXT,
    Record_Date DATE
);

-- 3. Chèn dữ liệu mẫu
INSERT INTO Records_North (Record_ID, Patient_Name, Diagnosis, Record_Date) VALUES
(1, 'Nguyen Van A', 'Sốt xuất huyết', '2023-10-01'),
(2, 'Tran Thi B', 'Viêm phổi', '2023-10-02');

INSERT INTO Records_South (Record_ID, Patient_Name, Diagnosis, Record_Date) VALUES
(1, 'Le Van C', 'Đau ruột thừa', '2023-10-01'), -- Trùng ID = 1 với miền Bắc
(3, 'Pham Thi D', 'Sốt rét', '2023-10-03');


CREATE VIEW National_Record_View AS
SELECT 
    Record_ID, 
    Patient_Name, 
    Diagnosis, 
    Record_Date,
    'North' AS Branch_Name -- Cột ảo định danh miền Bắc
FROM Records_North

UNION ALL

SELECT 
    Record_ID, 
    Patient_Name, 
    Diagnosis, 
    Record_Date,
    'South' AS Branch_Name -- Cột ảo định danh miền Nam
FROM Records_South;

SELECT * FROM National_Record_View;

/*
Mã Record_ID là Khóa chính (Primary Key), nhưng nó chỉ có tác dụng đảm bảo tính duy nhất bên trong phạm vi bảng của nó (Ví dụ: Miền Bắc chỉ có 1 ID = 1, Miền Nam chỉ có 1 ID = 1).

Lệnh UNION ALL có bản chất là "gộp tất cả, kể cả trùng lặp". Nó chỉ đơn giản là nối đuôi bảng kết quả thứ hai vào sau bảng kết quả thứ nhất mà không mất thời gian quét để loại bỏ các dòng giống nhau.

Nếu dùng lệnh UNION (không có ALL), hệ thống sẽ tốn thêm tài nguyên để tìm và loại bỏ các dòng trùng lặp hoàn toàn. Tuy nhiên, trong bài toán này, vì chúng ta đã tạo thêm cột ảo Branch_Name ('North' và 'South'),
 nên toàn bộ các dòng bản chất đã trở nên khác biệt nhau (Unique). Dù vậy, việc sử dụng UNION ALL vẫn là phương án chuẩn xác nhất về mặt nghiệp vụ để tránh mất mát bệnh án và tối ưu hóa hiệu năng hệ thống (bỏ qua bước Deduplication).
 
*/