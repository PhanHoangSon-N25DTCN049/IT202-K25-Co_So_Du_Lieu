-- 1. Bảng Khoa (Departments)
CREATE TABLE Departments (
    Department_ID INT PRIMARY KEY,
    Department_Name VARCHAR(100)
);

-- 2. Bảng Bệnh nhân (Patients)
CREATE TABLE Patients (
    Patient_ID INT PRIMARY KEY,
    Full_Name VARCHAR(100),
    Phone VARCHAR(15)
);

-- 3. Bảng Hóa đơn (Invoices)
CREATE TABLE Invoices (
    Invoice_ID INT PRIMARY KEY,
    Patient_ID INT,
    Department_ID INT,
    Amount DECIMAL(15, 2),
    FOREIGN KEY (Patient_ID) REFERENCES Patients(Patient_ID),
    FOREIGN KEY (Department_ID) REFERENCES Departments(Department_ID)
);

-- Chèn dữ liệu mẫu
INSERT INTO Departments VALUES (1, 'Khoa Noi'), (2, 'Khoa Ngoai');
INSERT INTO Patients VALUES (1, 'Nguyen Van A', '090111'), (2, 'Tran Thi B', '090222'), (3, 'Le Van C', '090333');
INSERT INTO Invoices VALUES 
(101, 1, 1, 500000),   -- Bệnh nhân 1 khám Khoa Nội
(102, 2, 1, 750000),   -- Bệnh nhân 2 khám Khoa Nội
(103, 3, 2, 1200000),  -- Bệnh nhân 3 khám Khoa Ngoại
(104, 1, 1, 200000);   -- Bệnh nhân 1 phát sinh thêm phí ở Khoa Nội

CREATE VIEW Department_Revenue_View AS
SELECT 
    d.Department_Name AS 'Tên khoa',
    COUNT(DISTINCT i.Patient_ID) AS 'Tổng số bệnh nhân',
    SUM(i.Amount) AS 'Tổng doanh thu'
FROM Departments d
JOIN Invoices i ON d.Department_ID = i.Department_ID
GROUP BY d.Department_Name;

SELECT * FROM Department_Revenue_View;

-- Thử dùng UPDATE để thay đổi tổng doanh thu của Khoa Nội
UPDATE Department_Revenue_View 
SET `Tổng doanh thu` = 9999000 
WHERE `Tên khoa` = 'Khoa Noi';