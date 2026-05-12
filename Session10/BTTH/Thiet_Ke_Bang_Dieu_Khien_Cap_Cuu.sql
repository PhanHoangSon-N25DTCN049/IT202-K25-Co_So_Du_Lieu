-- Tạo bảng Bệnh nhân
CREATE TABLE Patients (
    Patient_ID VARCHAR(5) PRIMARY KEY,
    Full_Name VARCHAR(100) NOT NULL,
    Admission_Time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tạo bảng Dữ liệu sinh tồn
CREATE TABLE Vitals_Logs (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID VARCHAR(5),
    Heart_Rate INT CHECK (Heart_Rate > 0),
    Blood_Pressure VARCHAR(20),
    Record_Time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Patient_ID) REFERENCES Patients(Patient_ID)
);

-- Thêm dữ liệu mẫu (Giả lập tình huống Cấp cứu)
INSERT INTO Patients (Patient_ID, Full_Name) VALUES 
('BN001', 'Nguyen Van A'), 
('BN002', 'Tran Thi B'), 
('BN003', 'Le Van C'); -- BN003 mới nhập viện, chưa có số đo

INSERT INTO Vitals_Logs (Patient_ID, Heart_Rate, Blood_Pressure, Record_Time) VALUES 
('BN001', 80, '120/80', '2023-10-01 10:00:00'),
('BN001', 130, '140/90', '2023-10-01 10:05:00'), -- Đây là bản ghi mới nhất của BN001 (Nhịp tim 130 -> CRITICAL)
('BN002', 75, '110/70', CURRENT_TIMESTAMP);      -- Bản ghi của BN002 (STABLE)

CREATE INDEX idx_patient_time ON Vitals_Logs(Patient_ID, Record_Time);

CREATE VIEW ER_Dashboard_View AS
SELECT 
    p.Patient_ID,
    p.Full_Name,
    -- Ép kiểu Heart_Rate sang chuỗi để kết hợp với chữ 'Pending'
    COALESCE(CAST(v.Heart_Rate AS CHAR), 'Pending') AS Heart_Rate_Display,
    COALESCE(v.Blood_Pressure, 'Pending') AS Blood_Pressure,
    -- Phân loại mức độ khẩn cấp
    CASE 
        WHEN v.Heart_Rate IS NULL THEN 'PENDING'
        WHEN v.Heart_Rate > 120 OR v.Heart_Rate < 50 THEN 'CRITICAL'
        ELSE 'STABLE'
    END AS Urgency_Level
FROM Patients p
LEFT JOIN (
    -- Subquery: Lấy ra toàn bộ thông tin của lần đo sinh tồn mới nhất
    SELECT v1.* FROM Vitals_Logs v1
    WHERE v1.Record_Time = (
        SELECT MAX(Record_Time) 
        FROM Vitals_Logs v2 
        WHERE v2.Patient_ID = v1.Patient_ID
    )
) v ON p.Patient_ID = v.Patient_ID;

SELECT * FROM ER_Dashboard_View;

-- Thử can thiệp sửa nhịp tim của bệnh nhân từ Dashboard
UPDATE ER_Dashboard_View 
SET Heart_Rate_Display = '80' 
WHERE Patient_ID = 'BN001';